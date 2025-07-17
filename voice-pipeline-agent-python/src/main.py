import asyncio
import logging
import os
from dotenv import load_dotenv
from livekit.agents import (
    AgentSession,
    AutoSubscribe,
    JobContext,
    JobProcess,
    WorkerOptions,
    cli,
    metrics,
    RoomInputOptions,
)
from livekit.plugins import (
    noise_cancellation,
    silero,
)
from aiohttp import web
from aiohttp.web_runner import GracefulExit


from agents.assistant import Assistant
from services.instructions_service import InstructionsService

if os.path.exists(".env.local"):
    load_dotenv(dotenv_path=".env.local")
else:
    load_dotenv()

logger = logging.getLogger("voice-agent")

health_server_task = None

global_runner = None
global_site = None

async def health_handler(request):
    """Health check endpoint for Kubernetes probes"""
    return web.Response(text="OK", status=200)

# Add this helper function to your file
def _log_task_exception(task: asyncio.Task) -> None:
    """Callback to log exceptions from a background task."""
    try:
        task.result()
    except asyncio.CancelledError:
        pass  # Task cancellation is expected on shutdown, so we can ignore it.
    except Exception:
        # This will log the full exception traceback.
        logger.exception("Exception caught in background health server task")


async def start_health_server(proc: JobProcess):
    """
    Start a server to handle health checks and gracefully shut it down
    when the agent worker shuts down.
    """
    logger.info("Health server task started.")
    app = web.Application()
    app.router.add_get('/health', health_handler)
    app.router.add_get('/ready', health_handler)

    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, '0.0.0.0', 8080)

    try:
        await site.start()
        logger.info("✅ Health check server is up and running on http://0.0.0.0:8080")
        
        # Keep the server running until the worker process begins to shut down
        await proc.shutdown_event.wait()
        
    except asyncio.CancelledError:
        # This is expected when the application is shutting down gracefully.
        logger.info("Health server task was cancelled.")
    except Exception:
        logger.exception("An exception occurred in the health server task.")
    finally:
        logger.info("Shutting down health check server...")
        await runner.cleanup()
        logger.info("Health check server shutdown complete.")


async def prewarm(proc: JobProcess):
    """
    This function is called when the worker starts.
    We'll start the health check server in a background task.
    """
    logger.info("Prewarm hook is executing. Starting health check server...")
    health_task = asyncio.create_task(start_health_server(proc))
    
    # Add the callback to ensure we see any exceptions from the task
    health_task.add_done_callback(_log_task_exception)

async def entrypoint(ctx: JobContext):
    logger.info(f"connecting to room {ctx.room.name}")
    await ctx.connect(auto_subscribe=AutoSubscribe.AUDIO_ONLY)

    # Wait for the first participant to connect
    participant = await ctx.wait_for_participant()
    logger.info(f"starting voice assistant for participant {participant.identity}")

    usage_collector = metrics.UsageCollector()

    # Log metrics and collect usage data
    def on_metrics_collected(agent_metrics: metrics.AgentMetrics):
        metrics.log_metrics(agent_metrics)
        usage_collector.collect(agent_metrics)

    session = AgentSession(
        vad=ctx.proc.userdata["vad"],
        # minimum delay for endpointing, used when turn detector believes the user is done with their turn
        min_endpointing_delay=0.5,
        # maximum delay for endpointing, used when turn detector does not believe the user is done with their turn
        max_endpointing_delay=5.0,
    )

    # Trigger the on_metrics_collected function when metrics are collected
    session.on("metrics_collected", on_metrics_collected)

    # Create services
    instructions_service = InstructionsService()

    await session.start(
        room=ctx.room,
        agent=Assistant(instructions_service),
        room_input_options=RoomInputOptions(
            # enable background voice & noise cancellation, powered by Krisp
            # included at no additional cost with LiveKit Cloud
            noise_cancellation=noise_cancellation.BVC(),
        ),
    )


if __name__ == "__main__":    
    
    cli.run_app(
        WorkerOptions(
            entrypoint_fnc=entrypoint,
            prewarm_fnc=prewarm,
        ),
    )