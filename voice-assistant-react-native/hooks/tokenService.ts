import { sign } from 'react-native-pure-jwt';

// Environment variables - these should be set in your .env file
const LIVEKIT_API_KEY = process.env.EXPO_PUBLIC_LIVEKIT_API_KEY;
const LIVEKIT_API_SECRET = process.env.EXPO_PUBLIC_LIVEKIT_API_SECRET;
const LIVEKIT_URL = process.env.EXPO_PUBLIC_LIVEKIT_URL;

interface TokenOptions {
  identity?: string;
  room?: string;
  name?: string;
}

interface ConnectionDetails {
  token: string;
  url: string;
}

export class TokenService {
  private static generateRandomIdentity(): string {
    // Generate random hex string for identity
    const array = new Uint8Array(4);
    if (typeof crypto !== 'undefined' && crypto.getRandomValues) {
      crypto.getRandomValues(array);
    } else {
      // Fallback for environments without crypto.getRandomValues
      for (let i = 0; i < array.length; i++) {
        array[i] = Math.floor(Math.random() * 256);
      }
    }
    const hex = Array.from(array)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
    return `user-${hex}`;
  }

  static async generateToken(options: TokenOptions = {}): Promise<ConnectionDetails> {
    if (!LIVEKIT_API_KEY || !LIVEKIT_API_SECRET || !LIVEKIT_URL) {
      throw new Error('LiveKit environment variables are not configured');
    }

    const identity = options.identity || this.generateRandomIdentity();
    const room = options.room || 'default-room';
    const name = options.name || identity;

    const now = Math.floor(Date.now() / 1000);
    const exp = now + (600); // 6 hours from now

    // Create JWT payload matching LiveKit's AccessToken format more closely
    const payload = {
      iss: LIVEKIT_API_KEY,
      sub: identity,
      name: name,
      iat: now,
      // Remove nbf as it's not used in the Python version
      video: {
        room: room,
        roomJoin: true,
        roomCreate: true,
        // Simplified grants - only include what's in Python version
      },
    };

    try {
      const token = await sign(payload, LIVEKIT_API_SECRET, {
        alg: 'HS256',
      });

      return {
        token,
        url: LIVEKIT_URL,
      };
    } catch (error) {
      throw new Error(`Failed to generate JWT token: ${error}`);
    }
  }
}