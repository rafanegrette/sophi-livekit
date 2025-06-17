import { useEffect, useState } from 'react';
import { TokenService } from './tokenService';

type ConnectionDetails = {
  url: string;
  token: string;
};

/**
 * Retrieves LiveKit connection details by generating a token.
 * Uses environment variables for API credentials.
 */
export function useConnectionDetails(): ConnectionDetails | undefined {
  const [details, setDetails] = useState<ConnectionDetails | undefined>();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const generateConnectionDetails = async () => {
      try {
        const connectionDetails = await TokenService.generateToken({
          room: 'default-room',
          // You can customize identity and name here if needed
        });
        setDetails(connectionDetails);
        setError(null);
      } catch (err) {
        console.error('Failed to generate token:', err);
        setError(err instanceof Error ? err.message : 'Unknown error');
        setDetails(undefined);
      }
    };

    generateConnectionDetails();
  }, []);

  // Optional: Log error for debugging
  useEffect(() => {
    if (error) {
      console.warn('Connection details error:', error);
    }
  }, [error]);

  return details;
}