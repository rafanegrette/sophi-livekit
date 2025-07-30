# Voice Assistant - Separation of Concerns

This document outlines the separation of concerns implemented in the voice assistant React Native application.

## Architecture Overview

The voice assistant has been refactored to separate audio logic from display logic, following the principle of separation of concerns.

## File Structure

### Audio Logic (Hooks)
- **`hooks/useAudioSession.ts`** - Manages AudioSession lifecycle (start/stop)
- **`hooks/useVoiceAssistantAudio.ts`** - Centralized audio state management including:
  - Microphone state and controls
  - Voice assistant state
  - Audio transcriptions (user and agent)
  - Audio track management

### Display Logic (Components)
- **`components/TranscriptionDisplay.tsx`** - Renders user and agent transcriptions with theme support
- **`components/VoiceVisualizer.tsx`** - Displays the voice assistant bar visualizer
- **`components/ControlButtons.tsx`** - Renders microphone and exit control buttons
- **`components/index.ts`** - Centralized component exports

### Main Application
- **`app/assistant/index.tsx`** - Main screen that orchestrates the separated components and hooks

## Benefits of This Architecture

### 1. **Single Responsibility**
- Each component/hook has a single, well-defined responsibility
- Audio logic is separated from UI rendering
- Easy to test individual pieces

### 2. **Reusability**
- Components can be reused in different contexts
- Audio hooks can be used in other screens that need voice functionality
- UI components are independent of business logic

### 3. **Maintainability**
- Changes to audio logic don't affect UI components
- UI styling changes don't impact audio functionality
- Clear boundaries between different concerns

### 4. **Testability**
- Hooks can be tested independently with React Testing Library
- UI components can be tested with snapshot testing
- Business logic is separated from presentation logic

## Usage Example

```tsx
// In any component that needs voice assistant functionality
function MyVoiceComponent() {
  const {
    isMicrophoneEnabled,
    voiceAssistantState,
    audioTrack,
    lastUserTranscription,
    lastAgentTranscription,
    toggleMicrophone,
  } = useVoiceAssistantAudio();

  return (
    <View>
      <VoiceVisualizer 
        state={voiceAssistantState} 
        audioTrack={audioTrack} 
      />
      <UserTranscriptionText text={lastUserTranscription} />
      <AgentTranscriptionText text={lastAgentTranscription} />
      <ControlButtons
        isMicrophoneEnabled={isMicrophoneEnabled}
        onToggleMicrophone={toggleMicrophone}
        onExit={() => {/* handle exit */}}
      />
    </View>
  );
}
```

## Key Principles Applied

1. **Separation of Concerns**: Audio logic separated from UI components
2. **Single Responsibility**: Each file has one clear purpose
3. **Dependency Inversion**: Components depend on abstractions (props) not concrete implementations
4. **Open/Closed**: Easy to extend with new features without modifying existing code
5. **DRY (Don't Repeat Yourself)**: Reusable components and hooks

## Future Enhancements

This architecture makes it easy to:
- Add new UI themes or layouts
- Implement different audio processing algorithms
- Add unit tests for each component/hook
- Extend functionality with new features
- Migrate to different state management solutions if needed
