import React from 'react';
import { View, Text, useColorScheme, StyleSheet } from 'react-native';
import Markdown from 'react-native-markdown-display';

interface UserTranscriptionProps {
  text: string;
}

interface AgentTranscriptionProps {
  text: string;
}

/**
 * Component to display user transcription with proper styling
 */
export const UserTranscriptionText: React.FC<UserTranscriptionProps> = ({ text }) => {
  const colorScheme = useColorScheme();
  const themeStyle =
    colorScheme === 'light'
      ? styles.userTranscriptionLight
      : styles.userTranscriptionDark;
  const themeTextStyle =
    colorScheme === 'light' ? styles.lightThemeText : styles.darkThemeText;

  if (!text) return null;

  const markdownStyle = {
    body: [styles.userTranscription, themeStyle, themeTextStyle],
    paragraph: { margin: 0 },
    text: themeTextStyle,
  };

  return (
    <View style={styles.userTranscriptionContainer}>
      <View style={[styles.userTranscription, themeStyle]}>
        <Markdown style={markdownStyle}>
          {text}
        </Markdown>
      </View>
    </View>
  );
};

/**
 * Component to display agent transcription with proper styling
 */
export const AgentTranscriptionText: React.FC<AgentTranscriptionProps> = ({ text }) => {
  const colorScheme = useColorScheme();
  const themeTextStyle =
    colorScheme === 'light' ? styles.lightThemeText : styles.darkThemeText;

  if (!text) return null;

  const markdownStyle = {
    body: [styles.agentTranscription, themeTextStyle],
    paragraph: { margin: 0 },
    text: themeTextStyle,
  };

  return (
    <View style={{ margin: 16 }}>
      <Markdown style={markdownStyle}>
        {text}
      </Markdown>
    </View>
  );
};

const styles = StyleSheet.create({
  userTranscriptionContainer: {
    width: '100%',
    alignContent: 'flex-end',
  },
  userTranscription: {
    width: 'auto',
    fontSize: 18,
    alignSelf: 'flex-end',
    borderRadius: 6,
    padding: 8,
    margin: 16,
  },
  userTranscriptionLight: {
    backgroundColor: '#B0B0B0',
  },
  userTranscriptionDark: {
    backgroundColor: '#404040',
  },
  agentTranscription: {
    fontSize: 20,
    textAlign: 'left',
    margin: 0, // Margin is now handled by the parent View
  },
  lightThemeText: {
    color: '#000000',
  },
  darkThemeText: {
    color: '#FFFFFF',
  },
});
