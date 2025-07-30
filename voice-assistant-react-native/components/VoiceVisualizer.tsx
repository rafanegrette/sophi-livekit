import React from 'react';
import { BarVisualizer } from '@livekit/react-native';
import { StyleSheet } from 'react-native';
import type { TrackReference } from '@livekit/react-native';

interface VoiceVisualizerProps {
  state: any; // Voice assistant state
  audioTrack: TrackReference | undefined;
}

/**
 * Component to display voice assistant visualization
 */
export const VoiceVisualizer: React.FC<VoiceVisualizerProps> = ({ 
  state, 
  audioTrack 
}) => {
  return (
    <BarVisualizer
      state={state}
      barCount={7}
      options={{
        minHeight: 0.5,
      }}
      trackRef={audioTrack}
      style={styles.voiceAssistant}
    />
  );
};

const styles = StyleSheet.create({
  voiceAssistant: {
    width: '100%',
    height: 100,
  },
});
