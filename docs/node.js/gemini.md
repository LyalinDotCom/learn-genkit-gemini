# Genkit with Gemini Models - Node.js/TypeScript Guide

## Overview

This guide provides comprehensive, up-to-date examples for using Google's Genkit framework with Gemini AI models. All code examples use the latest syntax and best practices as of July 2025.

**Recommended**: Always use the latest version of Genkit and plugins for best compatibility.

## Important: Google AI vs Vertex AI

**Always use Google AI plugin (`@genkit-ai/googleai`) by default.** 

- Google AI is simpler, requires only an API key, and supports all Gemini models
- Vertex AI should only be used when explicitly requested by the user
- Vertex AI requires Google Cloud project setup and authentication
- Both support the same models, but Google AI has easier setup

## Prerequisites

- Node.js 20+ and npm
- Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey)
- Basic TypeScript knowledge
- Latest Genkit: `npm install genkit @genkit-ai/core @genkit-ai/googleai zod`

## Core Concepts

### CRITICAL: Always Set Up npm run dev

**EVERY Genkit project MUST have package.json with this script:**
```json
{
  "scripts": {
    "dev": "genkit start -- npx tsx --watch src/index.ts"
  }
}
```

This allows users to simply run:
```bash
npm run dev
```

**NEVER** instruct users to type the full command `npx genkit start -- npx tsx --watch src/index.ts`.

### Important: Correct Imports

```typescript
// Core imports
import { genkit } from 'genkit';
import { UserFacingError, GenkitError } from '@genkit-ai/core';
import { googleAI } from '@genkit-ai/googleai';
import { z } from 'zod';

// Testing imports
import { testFlow } from 'genkit/testing';
```

### Error Handling Pattern

`UserFacingError` requires a status code as the first argument:

```typescript
// ✅ CORRECT - With status code
throw new UserFacingError('INTERNAL', 'Something went wrong');

// ❌ INCORRECT - Missing status code  
throw new UserFacingError('Something went wrong');

// Common status codes:
// 'INTERNAL' - General server errors
// 'INVALID_ARGUMENT' - Bad input from user
// 'NOT_FOUND' - Resource not found
// 'PERMISSION_DENIED' - Auth issues
```

### Modern Genkit Initialization

```typescript
import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/googleai';

const ai = genkit({
  plugins: [googleAI()],
  model: googleAI.model('gemini-2.5-flash'), // Default model
});
```

### Important: Model Reference Pattern

Always use the plugin's model method for model references:
```typescript
// ✅ CORRECT - Modern pattern
model: googleAI.model('gemini-2.5-flash')

// ❌ INCORRECT - Legacy string pattern
model: 'googleai/gemini-2.5-flash'
```

## Scenario Prompts & Implementations

### 1. Basic Text Generation

**Optimized Prompt for Gemini CLI:**
```
I need a story writing app using Genkit. Users should be able to enter any topic 
and get back a creative story about it. Give them options for story length 
(short, medium, or long). Use Gemini AI to generate the stories.
```

**Expected Implementation:**
```typescript
import { genkit } from 'genkit';
import { UserFacingError } from '@genkit-ai/core';
import { googleAI } from '@genkit-ai/googleai';
import { z } from 'zod';

const ai = genkit({
  plugins: [googleAI()],
  model: googleAI.model('gemini-2.5-flash'),
});

const generateStory = ai.defineFlow({
  name: 'generateStory',
  inputSchema: z.object({
    topic: z.string().describe('The topic for the story'),
    length: z.enum(['short', 'medium', 'long']).default('medium'),
  }),
  outputSchema: z.object({
    story: z.string(),
    wordCount: z.number(),
  }),
}, async (input) => {
  try {
    const lengthGuide = {
      short: '100-200 words',
      medium: '300-500 words',
      long: '800-1000 words'
    };

    const { text } = await ai.generate({
      model: googleAI.model('gemini-2.5-flash'),
      prompt: `Write a creative story about ${input.topic}. 
               Make it approximately ${lengthGuide[input.length]}.`,
    });

    const wordCount = text.split(/\s+/).length;

    return { story: text, wordCount };
  } catch (error) {
    throw new UserFacingError('INTERNAL', 'Failed to generate story. Please try again.');
  }
});

export { generateStory };
```

### 2. Single-Speaker Text-to-Speech

**Supported Voice Names:**
```
achernar, achird, algenib, algieba, alnilam, aoede, autonoe, callirrhoe, 
charon, despina, enceladus, erinome, fenrir, gacrux, iapetus, kore, 
laomedeia, leda, orus, puck, pulcherrima, rasalgethi, sadachbia, 
sadaltager, schedar, sulafat, umbriel, vindemiatrix, zephyr, zubenelgenubi
```

**Optimized Prompt for Gemini CLI:**
```
Build me a project that uses Genkit on the backend to take input from the user, 
translate it to Spanish from English and create an audio file using text-to-speech 
to read back the spanish text by generating the audio file. Use Gemini models for both tasks.
```

**Expected Implementation:**
```typescript
import { genkit } from 'genkit';
import { UserFacingError } from '@genkit-ai/core';
import { googleAI } from '@genkit-ai/googleai';
import { z } from 'zod';
import { Buffer } from 'buffer';
import { Writer as WavWriter } from 'wav';
import { PassThrough } from 'stream';

const ai = genkit({
  plugins: [googleAI()],
});

// Valid TTS voice names
const VALID_VOICES = [
  'achernar', 'achird', 'algenib', 'algieba', 'alnilam', 'aoede', 'autonoe', 
  'callirrhoe', 'charon', 'despina', 'enceladus', 'erinome', 'fenrir', 'gacrux', 
  'iapetus', 'kore', 'laomedeia', 'leda', 'orus', 'puck', 'pulcherrima', 
  'rasalgethi', 'sadachbia', 'sadaltager', 'schedar', 'sulafat', 'umbriel', 
  'vindemiatrix', 'zephyr', 'zubenelgenubi'
] as const;

// PCM to WAV conversion helper
async function pcmToWavDataUri(pcmData: Buffer, channels = 1, sampleRate = 24000, bitDepth = 16): Promise<string> {
  return new Promise((resolve, reject) => {
    const wavBufferChunks: Buffer[] = [];
    const passThrough = new PassThrough();

    passThrough.on('data', (chunk) => {
      wavBufferChunks.push(chunk as Buffer);
    });
    
    passThrough.on('end', () => {
      const wavBuffer = Buffer.concat(wavBufferChunks);
      const wavDataUri = `data:audio/wav;base64,${wavBuffer.toString('base64')}`;
      resolve(wavDataUri);
    });
    
    passThrough.on('error', reject);

    const writer = new WavWriter({
      channels: channels,
      sampleRate: sampleRate,
      bitDepth: bitDepth,
    });

    writer.on('error', reject);
    writer.pipe(passThrough);
    writer.write(pcmData);
    writer.end();
  });
}

// Flow 1: Translate text
const translateText = ai.defineFlow({
  name: 'translateText',
  inputSchema: z.object({
    text: z.string().min(1).max(5000),
    targetLanguage: z.string().default('es'),
  }),
  outputSchema: z.object({
    translatedText: z.string(),
    sourceLanguage: z.string(),
    targetLanguage: z.string(),
  }),
}, async (input) => {
  try {
    const response = await ai.generate({
      model: googleAI.model('gemini-2.5-flash'),
      prompt: `Translate the following English text to ${input.targetLanguage}. 
               Return only the translation, no explanations:
               "${input.text}"`,
    });

    return {
      translatedText: response.text.trim(),
      sourceLanguage: 'en',
      targetLanguage: input.targetLanguage,
    };
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `Translation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});

// Flow 2: Text to Speech
const textToSpeech = ai.defineFlow({
  name: 'textToSpeech',
  inputSchema: z.object({
    text: z.string().min(1).max(5000),
  }),
  outputSchema: z.object({
    audioDataUri: z.string(),
  }),
}, async (input) => {
  try {
    const response = await ai.generate({
      model: googleAI.model('gemini-2.5-flash-preview-tts'),
      prompt: input.text,
      config: {
        responseModalities: ['AUDIO'],
        speechConfig: {
          voiceConfig: {
            prebuiltVoiceConfig: { voiceName: 'algenib' }, // Default voice
          },
        },
      },
    });

    if (!response.media?.url) {
      throw new Error('No audio generated');
    }

    // Extract base64 PCM from data URI
    const base64StartIndex = response.media.url.indexOf(';base64,');
    if (base64StartIndex === -1) {
      throw new Error('Invalid audio data format');
    }
    const base64PcmData = response.media.url.substring(base64StartIndex + ';base64,'.length);
    const pcmBuffer = Buffer.from(base64PcmData, 'base64');
    
    // Convert PCM to WAV
    const wavDataUri = await pcmToWavDataUri(pcmBuffer, 1, 24000, 16);
    
    return {
      audioDataUri: wavDataUri,
    };
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `TTS generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});

export { translateText, textToSpeech };
```

### 3. Multi-Speaker Text-to-Speech

**Optimized Prompt for Gemini CLI:**
```
Build a Genkit app that creates podcast-style audio conversations. I want to 
write dialogue between two people and have the app generate audio where each 
person sounds different. For example: "Host: Welcome!" and "Guest: Thanks!" 
should have distinct voices. Use Gemini's text-to-speech.
```

**Expected Implementation:**
```typescript
import { genkit } from 'genkit';
import { UserFacingError } from '@genkit-ai/core';
import { googleAI } from '@genkit-ai/googleai';
import { z } from 'zod';
import { Buffer } from 'buffer';
import { Writer as WavWriter } from 'wav';
import { PassThrough } from 'stream';

const ai = genkit({
  plugins: [googleAI()],
});

// Valid TTS voice names (same as single-speaker)
const VALID_VOICES = [
  'achernar', 'achird', 'algenib', 'algieba', 'alnilam', 'aoede', 'autonoe', 
  'callirrhoe', 'charon', 'despina', 'enceladus', 'erinome', 'fenrir', 'gacrux', 
  'iapetus', 'kore', 'laomedeia', 'leda', 'orus', 'puck', 'pulcherrima', 
  'rasalgethi', 'sadachbia', 'sadaltager', 'schedar', 'sulafat', 'umbriel', 
  'vindemiatrix', 'zephyr', 'zubenelgenubi'
] as const;

// PCM to WAV conversion helper (reuse from single-speaker or import)
async function pcmToWavDataUri(pcmData: Buffer, channels = 1, sampleRate = 24000, bitDepth = 16): Promise<string> {
  return new Promise((resolve, reject) => {
    const wavBufferChunks: Buffer[] = [];
    const passThrough = new PassThrough();

    passThrough.on('data', (chunk) => {
      wavBufferChunks.push(chunk as Buffer);
    });
    
    passThrough.on('end', () => {
      const wavBuffer = Buffer.concat(wavBufferChunks);
      const wavDataUri = `data:audio/wav;base64,${wavBuffer.toString('base64')}`;
      resolve(wavDataUri);
    });
    
    passThrough.on('error', reject);

    const writer = new WavWriter({
      channels: channels,
      sampleRate: sampleRate,
      bitDepth: bitDepth,
    });

    writer.on('error', reject);
    writer.pipe(passThrough);
    writer.write(pcmData);
    writer.end();
  });
}

const generateDialogue = ai.defineFlow({
  name: 'generateDialogue',
  inputSchema: z.object({
    text: z.string().describe('Text with <speaker="Speaker1">...</speaker> tags'),
  }),
  outputSchema: z.object({
    audioDataUri: z.string(),
  }),
}, async (input) => {
  try {
    const response = await ai.generate({
      model: googleAI.model('gemini-2.5-flash-preview-tts'),
      prompt: input.text,
      config: {
        responseModalities: ['AUDIO'],
        speechConfig: {
          multiSpeakerVoiceConfig: {
            speakerVoiceConfigs: [
              {
                speaker: 'Speaker1',
                voiceConfig: {
                  prebuiltVoiceConfig: { voiceName: 'algenib' }, // Male-sounding voice
                },
              },
              {
                speaker: 'Speaker2',
                voiceConfig: {
                  prebuiltVoiceConfig: { voiceName: 'kore' }, // Female-sounding voice
                },
              },
            ],
          },
        },
      },
    });

    if (!response.media?.url) {
      throw new Error('No audio generated');
    }

    // Extract base64 PCM from data URI
    const base64StartIndex = response.media.url.indexOf(';base64,');
    if (base64StartIndex === -1) {
      throw new Error('Invalid audio data format');
    }
    const base64PcmData = response.media.url.substring(base64StartIndex + ';base64,'.length);
    const pcmBuffer = Buffer.from(base64PcmData, 'base64');
    
    // Convert PCM to WAV
    const wavDataUri = await pcmToWavDataUri(pcmBuffer, 1, 24000, 16);

    return {
      audioDataUri: wavDataUri,
    };
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `Dialogue generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});

export { generateDialogue };
```

### 4. Image Generation

For image generation, the cleanest approach is to create dedicated flows for each model or service you intend to support. This avoids complex conditional logic within a single flow and makes your code easier to maintain and test.

Below are three distinct patterns for image generation.

**Optimized Prompt for Gemini CLI:**
```
I need an AI image generator using Genkit. Users should be able to type what they want to see (like "a cat wearing a superhero cape") and get back a generated image. Provide separate, clean examples for generating images with the default Gemini model and the higher-quality Imagen model.
```

#### A. Default Image Generation with Gemini

This approach uses a powerful multimodal Gemini model. It's suitable for general-purpose image generation directly within a standard flow.

**Important Note**: The Gemini Flash image generation model returns images in a data URI format (`response.media.url`) that contains base64-encoded data, not as a separate image object. The implementation below handles both the Genkit-normalized response format and the raw API response format.

**Expected Implementation:**
```typescript
import { genkit } from 'genkit';
import { UserFacingError } from '@genkit-ai/core';
import { googleAI } from '@genkit-ai/googleai';
import { z } from 'zod';

const ai = genkit({
  plugins: [googleAI()],
});

export const generateImageWithGemini = ai.defineFlow({
  name: 'generateImageWithGemini',
  inputSchema: z.object({
    prompt: z.string().min(1).max(1000).describe('A description of the image to generate'),
  }),
  outputSchema: z.object({
    image: z.object({
      base64: z.string(),
      mimeType: z.string(),
    }),
    model: z.string(),
  }),
}, async (input) => {
  try {
    const response = await ai.generate({
      model: googleAI.model('gemini-2.0-flash-preview-image-generation'),
      prompt: `Generate an image based on this description: ${input.prompt}`,
      config: {
        responseModalities: ['IMAGE', 'TEXT'],
      },
    });

    // Check for response.media first (Genkit may normalize the response)
    if (response.media?.url) {
      // Extract base64 from data URI
      const base64Data = response.media.url.substring(
        response.media.url.indexOf(';base64,') + ';base64,'.length
      );
      return {
        image: {
          base64: base64Data,
          mimeType: response.media.contentType || 'image/png',
        },
        model: 'gemini-2.0-flash-preview-image-generation',
      };
    } 
    // Fallback to raw API response format
    else if (response.candidates?.[0]?.content?.parts) {
      for (const part of response.candidates[0].content.parts) {
        if (part.inlineData?.data) {
          return {
            image: {
              base64: part.inlineData.data,
              mimeType: part.inlineData.mimeType || 'image/png',
            },
            model: 'gemini-2.0-flash-preview-image-generation',
          };
        }
      }
    }
    
    throw new Error('No image was generated by the Gemini model.');
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `Gemini image generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});
```

#### B. High-Quality Image Generation with Imagen

When higher fidelity or more artistic control is needed, using the dedicated Imagen model is the recommended path. This requires a separate flow that calls the Imagen model directly.

**Important Notes**: 
- Imagen models require the `output: { format: 'media' }` parameter
- Genkit generates one image at a time, so multiple images require multiple API calls
- The response format is similar to Gemini Flash (data URI in `response.media.url`)
- Using Imagen 4 preview (`imagen-4.0-generate-preview-06-06`) for latest features and quality
- Requires paid tier API access

**Expected Implementation:**
```typescript
import { genkit } from 'genkit';
import { UserFacingError } from '@genkit-ai/core';
import { googleAI } from '@genkit-ai/googleai';
import { z } from 'zod';

const ai = genkit({
  plugins: [googleAI()],
});

export const generateImageWithImagen = ai.defineFlow({
  name: 'generateImageWithImagen',
  inputSchema: z.object({
    prompt: z.string().min(1).max(1000),
    style: z.string().optional().describe('e.g., "photorealistic", "anime", "watercolor"'),
    numberOfImages: z.number().min(1).max(4).default(1),
  }),
  outputSchema: z.object({
    images: z.array(z.object({
      base64: z.string(),
      mimeType: z.string(),
    })),
    model: z.string(),
  }),
}, async (input) => {
  try {
    const fullPrompt = input.style
      ? `${input.prompt}. Style: ${input.style}`
      : input.prompt;

    // Note: Genkit with Google AI currently generates one image at a time with Imagen
    // We'll generate multiple images by making multiple requests if needed
    const images = [];
    
    for (let i = 0; i < input.numberOfImages; i++) {
      const response = await ai.generate({
        model: googleAI.model('imagen-4.0-generate-preview-06-06'), // Use Imagen 4 preview
        prompt: fullPrompt,
        output: { format: 'media' }, // Request media output
      });

      if (response.media?.url) {
        // Extract base64 from data URI
        const base64Data = response.media.url.substring(
          response.media.url.indexOf(';base64,') + ';base64,'.length
        );
        images.push({
          base64: base64Data,
          mimeType: response.media.contentType || 'image/png',
        });
      }
    }

    if (images.length === 0) {
      throw new Error('No images were generated by the Imagen model.');
    }

    return {
      images,
      model: 'imagen-4.0-generate-preview-06-06',
    };
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `Imagen image generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});
```

#### C. Image Generation with Vertex AI (By Request Only)

This option should only be used when a project specifically requires Vertex AI for its infrastructure, security, or MLOps capabilities. It uses the `@genkit-ai/vertexai` plugin and requires Google Cloud project configuration.

**Prompt for Vertex AI Image Generation:**
```
Build a TypeScript Genkit project using Vertex AI for image generation. Requirements:
1. Use the vertexAI plugin instead of googleAI.
2. Configure it with the correct Google Cloud project settings.
3. Use the 'imagen-4.0-generate-preview-06-06' model.
4. Include instructions for authentication and setup.
```

**Vertex AI Implementation:**
```typescript
import { genkit } from 'genkit';
import { UserFacingError } from '@genkit-ai/core';
import { vertexAI } from '@genkit-ai/vertexai';
import { z } from 'zod';

// This configuration is required for Vertex AI
const ai = genkit({
  plugins: [vertexAI({
    projectId: process.env.GOOGLE_CLOUD_PROJECT, // Your Google Cloud Project ID
    location: 'us-central1', // Your GCP location
  })],
});

export const generateImageWithVertex = ai.defineFlow({
  name: 'generateImageWithVertex',
  inputSchema: z.object({
    prompt: z.string().min(1).max(1000),
    aspectRatio: z.enum(['1:1', '16:9', '9:16', '4:3']).default('1:1'),
    numberOfImages: z.number().min(1).max(4).default(1),
  }),
  outputSchema: z.object({
    images: z.array(z.object({
      base64: z.string(),
      mimeType: z.string(),
    })),
  }),
}, async (input) => {
  try {
    const response = await ai.generate({
      model: vertexAI.model('imagen-4.0-generate-preview-06-06'),
      prompt: input.prompt,
      config: {
        numberOfImages: input.numberOfImages,
        aspectRatio: input.aspectRatio,
      },
    });

    if (!response.media?.images || response.media.images.length === 0) {
      throw new Error('No images were generated by Vertex AI.');
    }

    return {
      images: response.media.images.map(img => ({
        base64: img.base64,
        mimeType: img.contentType || 'image/png',
      })),
    };
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `Vertex AI image generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});
```

### 5. Video Generation

**⚠️ COST WARNING**: Video generation has NO FREE TIER. Every request will be billed.

**Important Notes**:
- Text-to-video: Uses Veo 3 preview (`veo-3.0-generate-preview`) for latest features
- Image-to-video: Uses Veo 2 (`veo-2.0-generate-001`) as Veo 3 doesn't support this
- Video generation is asynchronous and requires polling using `ai.checkOperation()`
- Text-to-video (Veo 3): Fixed 8 seconds, 720p, 24fps
- Image-to-video (Veo 2): Variable 5-8 seconds, 720p, 30fps
- Video URLs require API key for download
- Requires `node-fetch` for downloading videos: `npm install node-fetch`

**Optimized Prompt for Gemini CLI:**
```
Build a video creation app with Genkit where users describe scenes in text 
and get AI-generated videos. Support both text-to-video and image-to-video 
generation. Include options for aspect ratio and negative prompts. Use 
Google's Veo 3 preview model for text-to-video and Veo 2 for image-to-video.
```

**Expected Implementation:**
```typescript
import { genkit, type MediaPart } from 'genkit';
import { UserFacingError } from '@genkit-ai/core';
import { googleAI } from '@genkit-ai/googleai';
import { z } from 'zod';
import * as fs from 'fs';
import { Readable } from 'stream';

const ai = genkit({
  plugins: [googleAI()],
});

// Helper function to download video to local file
async function downloadVideo(video: MediaPart, path: string): Promise<void> {
  const fetch = (await import('node-fetch')).default;
  
  // Add API key before fetching the video
  const videoDownloadResponse = await fetch(
    `${video.media!.url}&key=${process.env.GEMINI_API_KEY}`
  );
  
  if (!videoDownloadResponse || videoDownloadResponse.status !== 200 || !videoDownloadResponse.body) {
    throw new Error('Failed to fetch video');
  }

  return new Promise((resolve, reject) => {
    Readable.from(videoDownloadResponse.body as any)
      .pipe(fs.createWriteStream(path))
      .on('finish', resolve)
      .on('error', reject);
  });
}

// Text-to-Video Flow
const generateVideoFromText = ai.defineFlow({
  name: 'generateVideoFromText',
  inputSchema: z.object({
    prompt: z.string().min(10).max(2000).describe('Description of the video scene'),
    aspectRatio: z.enum(['16:9', '9:16']).default('16:9'),
    negativePrompt: z.string().optional().describe('What to avoid in the video'),
  }),
  outputSchema: z.object({
    videoUrl: z.string(),
    videoPath: z.string().optional(),
    metadata: z.object({
      duration: z.number(),
      resolution: z.string(),
      fps: z.number(),
      aspectRatio: z.string(),
    }),
  }),
}, async (input) => {
  console.warn('⚠️ Video generation request - This will incur charges!');
  
  try {
    // Note: Veo 3 uses different config parameters than Veo 2
    let { operation } = await ai.generate({
      model: googleAI.model('veo-3.0-generate-preview'),
      prompt: input.prompt,
      config: {
        // Veo 3 specific configuration
        aspectRatio: input.aspectRatio,
        negativePrompt: input.negativePrompt,
      },
    });

    if (!operation) {
      throw new Error('Expected the model to return an operation');
    }

    // Wait until the operation completes
    while (!operation.done) {
      operation = await ai.checkOperation(operation);
      // Sleep for 5 seconds before checking again
      await new Promise((resolve) => setTimeout(resolve, 5000));
    }

    if (operation.error) {
      throw new Error('Failed to generate video: ' + operation.error.message);
    }

    const video = operation.output?.message?.content.find((p) => !!p.media);
    if (!video) {
      throw new Error('Failed to find the generated video');
    }

    // Download video to local file
    const videoPath = `./output-${Date.now()}.mp4`;
    await downloadVideo(video, videoPath);

    return {
      videoUrl: video.media.url,
      videoPath,
      metadata: {
        duration: 8, // Veo 3 generates 8-second videos
        resolution: '720p',
        fps: 24,
        aspectRatio: input.aspectRatio,
      },
    };
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `Video generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});

// Image-to-Video Flow (Veo 2 only - Veo 3 doesn't support image-to-video)
const generateVideoFromImage = ai.defineFlow({
  name: 'generateVideoFromImage',
  inputSchema: z.object({
    prompt: z.string().min(10).max(2000).describe('Description of the video motion'),
    imageBase64: z.string().describe('Base64 encoded starting image'),
    imageMimeType: z.string().default('image/png'),
    aspectRatio: z.enum(['16:9', '9:16']).default('16:9'),
    durationSeconds: z.number().min(5).max(8).default(5).describe('Video duration in seconds (Veo 2)'),
  }),
  outputSchema: z.object({
    videoUrl: z.string(),
    videoPath: z.string().optional(),
    metadata: z.object({
      duration: z.number(),
      resolution: z.string(),
      fps: z.number(),
      aspectRatio: z.string(),
    }),
  }),
}, async (input) => {
  console.warn('⚠️ Video generation request - This will incur charges!');
  
  try {
    // Use Veo 2 for image-to-video generation
    let { operation } = await ai.generate({
      model: googleAI.model('veo-2.0-generate-001'),
      prompt: [
        {
          text: input.prompt,
        },
        {
          media: {
            contentType: input.imageMimeType,
            url: `data:${input.imageMimeType};base64,${input.imageBase64}`,
          },
        },
      ],
      config: {
        durationSeconds: input.durationSeconds,
        aspectRatio: input.aspectRatio,
        personGeneration: 'allow_adult',
      },
    });

    if (!operation) {
      throw new Error('Expected the model to return an operation');
    }

    // Wait until the operation completes
    while (!operation.done) {
      operation = await ai.checkOperation(operation);
      // Sleep for 5 seconds before checking again
      await new Promise((resolve) => setTimeout(resolve, 5000));
    }

    if (operation.error) {
      throw new Error('Failed to generate video: ' + operation.error.message);
    }

    const video = operation.output?.message?.content.find((p) => !!p.media);
    if (!video) {
      throw new Error('Failed to find the generated video');
    }

    // Download video to local file
    const videoPath = `./output-${Date.now()}.mp4`;
    await downloadVideo(video, videoPath);

    return {
      videoUrl: video.media.url,
      videoPath,
      metadata: {
        duration: input.durationSeconds,
        resolution: '720p',
        fps: 30, // Veo 2 uses 30fps
        aspectRatio: input.aspectRatio,
      },
    };
  } catch (error) {
    throw new UserFacingError(
      'INTERNAL',
      `Video generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    );
  }
});

export { generateVideoFromText, generateVideoFromImage };
```

## Next.js Integration

### Installation

```bash
npm install genkit @genkit-ai/core @genkit-ai/googleai @genkit-ai/next zod
```

### App Router Integration

**app/api/genkit/route.ts:**
```typescript
import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/googleai';
import { appRoute } from '@genkit-ai/next';

const ai = genkit({
  plugins: [googleAI()],
});

const myFlow = ai.defineFlow({
  name: 'myFlow',
  // ... flow definition
}, async (input) => {
  // ... implementation
});

// Export the route handler
export const POST = appRoute(ai, myFlow);
```

### Client-Side Usage

**components/AIComponent.tsx:**
```typescript
'use client';

import { runFlow, streamFlow } from '@genkit-ai/next/client';
import { useState } from 'react';

export function AIComponent() {
  const [result, setResult] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const handleGenerate = async () => {
    setLoading(true);
    try {
      // For non-streaming response
      const response = await runFlow('/api/genkit', {
        input: { prompt: 'Hello AI' }
      });
      setResult(response.output);
    } catch (error) {
      console.error('Generation failed:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStream = async () => {
    setLoading(true);
    setResult('');
    try {
      // For streaming response
      const stream = streamFlow('/api/genkit', {
        input: { prompt: 'Tell me a story' }
      });

      for await (const chunk of stream) {
        setResult(prev => prev + chunk);
      }
    } catch (error) {
      console.error('Streaming failed:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <button onClick={handleGenerate} disabled={loading}>
        Generate
      </button>
      <button onClick={handleStream} disabled={loading}>
        Stream
      </button>
      <div>{result}</div>
    </div>
  );
}
```

### Next.js Middleware Support

**middleware.ts:**
```typescript
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Add API key from environment
  const requestHeaders = new Headers(request.headers);
  requestHeaders.set('x-api-key', process.env.GEMINI_API_KEY || '');

  return NextResponse.next({
    request: {
      headers: requestHeaders,
    },
  });
}

export const config = {
  matcher: '/api/genkit/:path*',
};
```

## Production Best Practices

### 1. Error Handling

```typescript
import { genkit } from 'genkit';
import { UserFacingError, GenkitError } from '@genkit-ai/core';

const robustFlow = ai.defineFlow({
  name: 'robustFlow',
  // ... schemas
}, async (input) => {
  try {
    // Main logic
  } catch (error) {
    if (error instanceof GenkitError) {
      // Log internally but show user-friendly message
      console.error('Genkit error:', error);
      throw new UserFacingError('INTERNAL', 'Service temporarily unavailable');
    }
    throw new UserFacingError('INTERNAL', 'An unexpected error occurred');
  }
});
```

### 2. Environment Configuration

**.env.local:**
```
GEMINI_API_KEY=your-api-key
GENKIT_ENV=production
GENKIT_LOG_LEVEL=info
```

**src/config.ts:**
```typescript
import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/googleai';

export const ai = genkit({
  plugins: [googleAI({
    apiKey: process.env.GEMINI_API_KEY,
  })],
  model: googleAI.model('gemini-2.5-flash'),
  enableTracking: process.env.NODE_ENV === 'production',
});
```

### 3. Deployment Scripts

**package.json:**
```json
{
  "scripts": {
    "dev": "genkit start -- npx tsx --watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "deploy": "npm run build && gcloud run deploy",
    "test": "jest",
    "lint": "eslint . --ext .ts,.tsx",
    "typecheck": "tsc --noEmit"
  }
}
```

## Common Patterns

### 1. Reusable Schemas

```typescript
const ai = genkit({
  plugins: [googleAI()],
});

// Define reusable schemas
const PersonSchema = ai.defineSchema('PersonSchema', z.object({
  name: z.string(),
  age: z.number(),
  email: z.string().email(),
}));

const CompanySchema = ai.defineSchema('CompanySchema', z.object({
  name: z.string(),
  employees: z.array(PersonSchema),
}));
```

### 2. Tool Calling

```typescript
const toolCallingFlow = ai.defineFlow({
  name: 'toolCallingFlow',
  // ... schemas
}, async (input) => {
  const response = await ai.generate({
    model: googleAI.model('gemini-2.5-flash'),
    prompt: input.prompt,
    tools: [{
      name: 'getCurrentWeather',
      description: 'Get the current weather for a location',
      parameters: {
        type: 'object',
        properties: {
          location: { type: 'string' },
          unit: { type: 'string', enum: ['celsius', 'fahrenheit'] }
        },
        required: ['location']
      }
    }],
  });

  // Handle tool calls
  if (response.toolCalls) {
    // Process tool calls
  }

  return response.text;
});
```

### 3. Multimodal Input

```typescript
const analyzeImage = ai.defineFlow({
  name: 'analyzeImage',
  inputSchema: z.object({
    imageBase64: z.string(),
    question: z.string(),
  }),
  outputSchema: z.string(),
}, async (input) => {
  const response = await ai.generate({
    model: googleAI.model('gemini-2.5-flash'),
    prompt: [
      { text: input.question },
      { media: { contentType: 'image/jpeg', data: input.imageBase64 } }
    ],
  });

  return response.text;
});
```

## Testing Your Flows

### Running DevUI

```bash
# Set your API key
export GEMINI_API_KEY="your-api-key"

# Start DevUI
npm run dev

# Access at http://localhost:4000
```

### Unit Testing

```typescript
import { testFlow } from 'genkit/testing';
import { generateStory } from './flows';

describe('Story Generation', () => {
  it('should generate a story', async () => {
    const result = await testFlow(generateStory, {
      topic: 'space exploration',
      length: 'short',
    });

    expect(result.story).toBeTruthy();
    expect(result.wordCount).toBeGreaterThan(50);
    expect(result.wordCount).toBeLessThan(300);
  });
});
```

## Troubleshooting

### Common Issues

1. **"Cannot find model" error**
   - Use `googleAI.model()` pattern, not string references
   - Ensure the model name is correct and supported

2. **"No media in response" for TTS/Image/Video**
   - Check that you're using the correct model
   - Verify your API key has access to the model
   - Ensure proper config parameters are passed

3. **Type errors with flows**
   - Always define input and output schemas
   - Use zod for runtime validation
   - Export flow types for client usage

4. **Next.js build errors**
   - Ensure all Genkit code is in server components or API routes
   - Use the client helper functions for client components
   - Check that environment variables are available at build time

## Additional Resources

- [Genkit Documentation](https://firebase.google.com/docs/genkit)
- [Google AI Studio](https://aistudio.google.com/)
- [Gemini API Reference](https://ai.google.dev/api)
- [Genkit GitHub](https://github.com/firebase/genkit)

---

Last updated: July 2025 | Latest Genkit Version