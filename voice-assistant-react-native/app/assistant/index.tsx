import {
  StyleSheet,
  View,
  ScrollView,
} from 'react-native';

import React from 'react';
import {
  LiveKitRoom,
  useIOSAudioManagement,
  useRoomContext,
} from '@livekit/react-native';
import { useConnectionDetails } from '@/hooks/useConnectionDetails';
import { useAudioSession } from '@/hooks/useAudioSession';
import { useVoiceAssistantAudio } from '@/hooks/useVoiceAssistantAudio';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { UserTranscriptionText, AgentTranscriptionText, VoiceVisualizer, ControlButtons } from '@/components';

export default function AssistantScreen() {
  // Start the audio session first.
  useAudioSession();

  const connectionDetails = useConnectionDetails();

  return (
    <SafeAreaView>
      <LiveKitRoom
        serverUrl={connectionDetails?.url}
        token={connectionDetails?.token}
        connect={true}
        audio={true}
        video={false}
      >
        <RoomView />
      </LiveKitRoom>
    </SafeAreaView>
  );
}

const RoomView = () => {
  const router = useRouter();
  const room = useRoomContext();
  useIOSAudioManagement(room, true);

  // Use the separated audio logic hook
  const {
    isMicrophoneEnabled,
    voiceAssistantState,
    audioTrack,
    lastUserTranscription,
    lastAgentTranscription,
    toggleMicrophone,
  } = useVoiceAssistantAudio();

  const handleExit = () => {
    router.back();
  };

  return (
    <View style={styles.container}>
      <VoiceVisualizer 
        state={voiceAssistantState} 
        audioTrack={audioTrack} 
      />
      <ScrollView style={styles.logContainer}>
        <UserTranscriptionText text={lastUserTranscription} />
        <AgentTranscriptionText text={lastAgentTranscription} />
      </ScrollView>

      <ControlButtons
        isMicrophoneEnabled={isMicrophoneEnabled}
        onToggleMicrophone={toggleMicrophone}
        onExit={handleExit}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
    height: '100%',
    alignItems: 'center',
  },
  logContainer: {
    width: '100%',
    flex: 1,
    flexDirection: 'column',
  },
});
