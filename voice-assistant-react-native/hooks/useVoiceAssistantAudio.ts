import { useMemo } from 'react';
import {
  useLocalParticipant,
  useParticipantTracks,
  useTrackTranscription,
  useVoiceAssistant,
} from '@livekit/react-native';
import { Track } from 'livekit-client';

/**
 * Custom hook that manages all voice assistant audio logic
 * Returns audio state, transcriptions, and control functions
 */
export function useVoiceAssistantAudio() {
  const { isMicrophoneEnabled, localParticipant } = useLocalParticipant();
  const { agentTranscriptions, state, audioTrack } = useVoiceAssistant();

  // Get local audio tracks for transcription
  const localTracks = useParticipantTracks(
    [Track.Source.Microphone],
    localParticipant.identity
  );
  
  const { segments: userTranscriptions } = useTrackTranscription(
    localTracks[0]
  );

  // Get the latest transcriptions
  const lastUserTranscription = useMemo(() => {
    return userTranscriptions.length > 0
      ? userTranscriptions[userTranscriptions.length - 1].text
      : '';
  }, [userTranscriptions]);

  const lastAgentTranscription = useMemo(() => {
    return agentTranscriptions.length > 0
      ? agentTranscriptions[agentTranscriptions.length - 1].text
      : '';
  }, [agentTranscriptions]);

  // Audio control functions
  const toggleMicrophone = () => {
    localParticipant.setMicrophoneEnabled(!isMicrophoneEnabled);
  };

  return {
    // Audio state
    isMicrophoneEnabled,
    voiceAssistantState: state,
    audioTrack,
    
    // Transcriptions
    userTranscriptions,
    agentTranscriptions,
    lastUserTranscription,
    lastAgentTranscription,
    
    // Control functions
    toggleMicrophone,
  };
}
