import { useEffect } from 'react';
import { AudioSession } from '@livekit/react-native';

/**
 * Custom hook to manage audio session lifecycle
 * Handles starting and stopping the audio session
 */
export function useAudioSession() {
  useEffect(() => {
    let start = async () => {
      await AudioSession.startAudioSession();
    };

    start();
    return () => {
      AudioSession.stopAudioSession();
    };
  }, []);
}
