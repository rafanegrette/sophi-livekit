import React from 'react';
import { View, Image, Pressable, StyleSheet } from 'react-native';

interface ControlButtonsProps {
  isMicrophoneEnabled: boolean;
  onToggleMicrophone: () => void;
  onExit: () => void;
}

/**
 * Component for voice assistant control buttons
 */
export const ControlButtons: React.FC<ControlButtonsProps> = ({
  isMicrophoneEnabled,
  onToggleMicrophone,
  onExit,
}) => {
  const micImage = isMicrophoneEnabled
    ? require('../assets/images/baseline_mic_white_24dp.png')
    : require('../assets/images/baseline_mic_off_white_24dp.png');

  const exitImage = require('../assets/images/close_white_24dp.png');

  return (
    <View style={styles.controlsContainer}>
      <Pressable
        style={({ pressed }) => [
          { backgroundColor: pressed ? 'rgb(210, 230, 255)' : '#007DFF' },
          styles.button,
        ]}
        onPress={onToggleMicrophone}
      >
        <Image style={styles.icon} source={micImage} />
      </Pressable>
      <Pressable
        style={({ pressed }) => [
          {
            backgroundColor: pressed ? 'rgb(210, 230, 255)' : '#FF0000',
          },
          styles.button,
        ]}
        onPress={onExit}
      >
        <Image style={styles.icon} source={exitImage} />
      </Pressable>
    </View>
  );
};

const styles = StyleSheet.create({
  controlsContainer: {
    alignItems: 'center',
    flexDirection: 'row',
  },
  button: {
    width: 60,
    height: 60,
    padding: 10,
    margin: 12,
    borderRadius: 30,
  },
  icon: {
    width: 40,
    height: 40,
  },
});
