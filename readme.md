# Genkit Exploration with Gemini CLI

This repository is a collection of explorations and examples of how to use [Genkit](https://firebase.google.com/docs/genkit) with the Gemini CLI. The goal is to provide a hands-on guide for developers who want to get started with Genkit and Gemini for building AI-powered features.

**Recommendation**: Always use the latest versions of Genkit and its plugins for best compatibility.

## 🚀 Quick Start

### Prerequisites
- macOS (Intel or Apple Silicon)
- Node.js 20+ installed
- Gemini CLI installed (`npm install -g @genkit-ai/cli`)

### Using the Example Runner Script

This repository includes a convenient script to quickly generate any of the documented examples:

```bash
# Make the script executable (only needed once)
chmod +x run-example.sh

# Run the script (interactive mode - will ask for confirmations)
./run-example.sh

# Run in YOLO mode (auto-approves all tool calls)
./run-example.sh --yolo

# Alternative: source the script to stay in the generated directory
# source run-example.sh
```

The script will:
1. ✅ Check if Gemini CLI is installed (and provide install instructions if not)
2. 🎯 Present a menu of all available examples from this README
3. 📁 Create a new folder for your selected example (auto-increments if folder exists)
4. 📄 Copy `gemini.md` documentation to the project folder
5. 🤖 Run Gemini CLI with the appropriate prompt to generate the code

Each generated example will be placed in its own folder like `genkit-learn-text-generation-001`, `genkit-learn-tts-002`, etc.

**⚠️ YOLO Mode Warning**: When using `--yolo`, Gemini CLI will automatically approve all actions including file creation, package installation, and command execution. Use with caution!

## 📚 Repository Structure

The repository is organized by language, with each language having its own directory under the `docs` folder:

```
docs/
└── nodejs/
    └── gemini.md    # Comprehensive Node.js guide for Genkit with Gemini
```

## 🚀 Features & Scenarios

### ✅ Basic Inference (Text Generation)
**Status:** `Tested ✓`

Simple text generation using Gemini models through Genkit flows.

#### 🎯 Use Case
Build a creative story generation service that:
1. Takes a topic and generates stories of varying lengths
2. Uses Gemini 2.5 Flash for fast, creative responses
3. Returns word count along with the story

#### 💻 Example Prompt for Gemini CLI
```
I need a story writing app using Genkit. Users should be able to enter any topic 
and get back a creative story about it. Give them options for story length 
(short, medium, or long). Use Gemini AI to generate the stories.
```

#### ✨ Expected Results
- ✓ Fully functional Genkit project with story generation flow
- ✓ Node.js 20+ and TypeScript environment configured automatically
- ✓ All dependencies installed (genkit, @genkit-ai/core, @genkit-ai/googleai, zod)
- ✓ Input validation for topic and length selection
- ✓ Word count tracking in output
- ✓ TypeScript code that compiles successfully
- ✓ DevUI integration for testing
- ✓ Requires Gemini API key to be set as `GEMINI_API_KEY` environment variable

#### 📥 Sample Input
```json
{
  "topic": "a robot learning to paint",
  "length": "medium"
}
```

#### 📤 Sample Output
```json
{
  "story": "In a small workshop filled with canvases and paint...",
  "wordCount": 427
}
```

#### 🛠️ Running the Project
```bash
# Set your API key
export GEMINI_API_KEY="your-api-key-here"

# Start Genkit DevUI
genkit start -- npx tsx --watch src/index.ts

# Access the UI at http://localhost:4000
```

---

### 🔊 Text-to-Speech Generation: Single Speaker
**Status:** `Tested ✓`

Transform text into natural-sounding speech using Gemini's TTS capabilities.

#### 🎯 Use Case
Build a translation and text-to-speech service with two flows:
1. translateText: Translates English text to Spanish using Gemini
2. textToSpeech: Generates audio from any text input
3. Returns playable WAV files in DevUI

#### 💻 Example Prompt for Gemini CLI
```
Build me a project that uses Genkit on the backend to take input from the user, 
translate it to Spanish from English and create an audio file using text-to-speech 
to read back the spanish text by generating the audio file. Use Gemini models for both tasks.
```

#### ✨ Expected Results
- ✓ Two separate flows: translateText and textToSpeech
- ✓ Node.js 20+ environment with all dependencies auto-installed
- ✓ Translation flow converts English to Spanish
- ✓ TTS flow generates WAV audio from any text
- ✓ Audio output playable directly in DevUI
- ✓ TypeScript code that compiles successfully
- ✓ Includes wav package for PCM to WAV conversion
- ✓ Requires Gemini API key as environment variable

#### 🛠️ Running the Project
```bash
# Set your API key
export GEMINI_API_KEY="your-api-key-here"

# Start Genkit DevUI
genkit start -- npx tsx --watch src/index.ts

# Access the UI at http://localhost:4000
```

#### ⚠️ Important Notes
- Gemini API key is required (project will error without it - by design)
- Genkit DevUI must be run interactively (cannot be automated from CLI)
- Audio output is accessible directly through the DevUI interface

---

### 🔊 Text-to-Speech Generation: Multi-Speaker
**Status:** `Tested ✓`

Generate conversational audio with multiple distinct voices for realistic dialogues.

#### 🎯 Use Case
Build a dialogue generation service that:
1. Uses speaker tags format: `<speaker="Speaker1">text</speaker>`
2. Supports two different voices in a single audio file
3. Generates conversational audio with proper voice switching
4. Returns a single WAV file with both speakers

#### 💻 Example Prompt for Gemini CLI
```
Build a Genkit app that creates podcast-style audio conversations. I want to 
write dialogue between two people and have the app generate audio where each 
person sounds different. For example: "Host: Welcome!" and "Guest: Thanks!" 
should have distinct voices. Use Gemini's text-to-speech.
```

#### ✨ Expected Results
- ✓ Single audio file with multiple speakers
- ✓ Complete project with Node.js 20+ and all dependencies
- ✓ Voice switching based on speaker tags
- ✓ Speaker1 uses 'algenib' voice, Speaker2 uses 'kore' voice
- ✓ WAV audio playable directly in DevUI
- ✓ Requires Gemini API key with TTS model access

#### 📥 Sample Input
```json
{
  "text": "<speaker=\"Speaker1\">Welcome to our podcast about AI!</speaker> <speaker=\"Speaker2\">Thanks for having me. I'm excited to discuss the future.</speaker> <speaker=\"Speaker1\">Let's start with Genkit. What makes it special?</speaker>"
}
```

#### 📤 Sample Output
```json
{
  "audioDataUri": "data:audio/wav;base64,UklGRi..."
}
```

#### ⚠️ Important Notes
- Must include `responseModalities: ['AUDIO']` in config
- Speaker tags must match exactly: `<speaker="Speaker1">` not `<speaker=Speaker1>`
- Only two speakers supported per request
- Audio is returned as base64 PCM data (converted to WAV)
- Default voices: 'algenib' for Speaker1, 'kore' for Speaker2

---

### 🖼️ Image Generation with Gemini Flash
**Status:** `Ready for Testing`

Fast, accessible image generation using Gemini's built-in image generation capabilities.

#### 🎯 Use Case
Build a quick image generation service that:
1. Uses Gemini Flash for fast image generation
2. Supports creative prompts and descriptions
3. Returns base64 images for immediate display
4. Ideal for prototyping and general use cases

#### 💻 Example Prompt for Gemini CLI
```
I need an AI image generator using Genkit with Gemini Flash. Users should be 
able to type what they want to see (like "a cat wearing a superhero cape") 
and get back a generated image quickly. Use the Gemini Flash model for fast 
image generation.
```

#### ✨ Expected Results
- ✓ Complete Genkit project with Gemini Flash image generation
- ✓ Single flow: `generateImageWithGemini`
- ✓ Base64 image output for DevUI display
- ✓ Fast generation times
- ✓ Uses Google AI plugin (not Vertex AI)
- ✓ Requires only basic Gemini API key

#### 📥 Sample Input
```json
{
  "prompt": "A serene Japanese garden with cherry blossoms"
}
```

#### 📤 Sample Output
```json
{
  "image": {
    "base64": "iVBORw0KGgoAAAANS...",
    "mimeType": "image/png"
  },
  "model": "gemini-2.0-flash-preview-image-generation"
}
```

---

### 🎨 High-Quality Image Generation with Imagen
**Status:** `Ready for Testing`

Premium image generation using Google's dedicated Imagen models for superior quality.

#### 🎯 Use Case
Build a high-quality image generation service that:
1. Uses Imagen 4 preview for superior image quality
2. Supports advanced style controls
3. Can generate multiple images (via multiple API calls)
4. Ideal for professional or artistic use cases

#### 💻 Example Prompt for Gemini CLI
```
Build an image generator with Genkit using Google's Imagen 4 preview model. I want 
high-quality, professional images with style controls (like "photorealistic" 
or "watercolor"). Users should be able to generate multiple variations of 
their prompt.
```

#### ✨ Expected Results
- ✓ Complete Genkit project with Imagen integration
- ✓ Single flow: `generateImageWithImagen`
- ✓ Style customization options
- ✓ Multiple image generation (via looped API calls)
- ✓ Base64 image output for DevUI display
- ✓ Higher quality than Gemini Flash
- ✓ Uses Google AI plugin (not Vertex AI)
- ✓ Requires paid tier Gemini API key with Imagen access

#### 📥 Sample Input
```json
{
  "prompt": "A futuristic cityscape at sunset",
  "style": "photorealistic",
  "numberOfImages": 2
}
```

#### 📤 Sample Output
```json
{
  "images": [
    {
      "base64": "iVBORw0KGgoAAAANS...",
      "mimeType": "image/png"
    },
    {
      "base64": "jWCPRw1LKgoAAAANS...",
      "mimeType": "image/png"
    }
  ],
  "model": "imagen-4.0-generate-preview-06-06"
}
```

#### ⚠️ Important Notes
- Imagen 4 preview offers the latest features and best quality
- Requires paid tier API key (no free tier for Imagen)
- Multiple images are generated via sequential API calls
- Best for professional or artistic applications where quality matters most

---

### 🎬 Video Generation (Veo 3 & Veo 2)
**Status:** `Ready for Testing`

Generate video content from text prompts (Veo 3) or starting images (Veo 2).

#### ⚠️ COST WARNING
**Video generation has NO FREE TIER in Gemini API.** Each video generation request will incur charges.
- Fixed parameters: 8 seconds duration, 720p resolution, 24fps
- Current pricing: Check [Google AI Studio Pricing](https://ai.google.dev/pricing) for latest rates

#### 🎯 Use Case
Build a video generation service with two flows:
1. **generateVideoFromText**: Creates videos from text descriptions (Veo 3)
2. **generateVideoFromImage**: Creates videos from a starting image (Veo 2)
3. Supports aspect ratio selection (16:9, 9:16)
4. Includes negative prompts to exclude unwanted elements (Veo 3 only)
5. Returns video URL after asynchronous generation

#### 💻 Example Prompt for Gemini CLI
```
Build a video creation app with Genkit where users describe scenes in text 
and get AI-generated videos. Support both text-to-video and image-to-video 
generation. Include options for aspect ratio and negative prompts. Use 
Google's Veo 3 preview model for text-to-video and Veo 2 for image-to-video.
```

#### ✨ Expected Results
- ✓ Complete project with Node.js 20+ and all dependencies
- ✓ Two flows: text-to-video (Veo 3) and image-to-video (Veo 2)
- ✓ Asynchronous video generation with polling via `ai.checkOperation()`
- ✓ Aspect ratio options (16:9, 9:16)
- ✓ Negative prompt support (Veo 3 only)
- ✓ Videos automatically downloaded locally
- ✓ Text-to-video: 8 seconds fixed, 720p, 24fps (Veo 3)
- ✓ Image-to-video: 5-8 seconds variable, 720p, 30fps (Veo 2)
- ✓ Cost warnings prominently displayed
- ✓ Requires Gemini API key with Veo model access AND billing enabled

#### 📥 Sample Input (Text-to-Video)
```json
{
  "prompt": "A time-lapse of a flower blooming in a garden, with soft morning light",
  "aspectRatio": "16:9",
  "negativePrompt": "cartoon, animated, low quality"
}
```

#### 📥 Sample Input (Image-to-Video)
```json
{
  "prompt": "Camera slowly zooms in while petals gently sway in the breeze",
  "imageBase64": "iVBORw0KGgoAAAANS...",
  "imageMimeType": "image/png",
  "aspectRatio": "16:9",
  "negativePrompt": "blurry, distorted"
}
```

#### 📤 Sample Output
```json
{
  "videoUrl": "https://storage.googleapis.com/...",
  "videoPath": "./output-1737123456789.mp4",
  "metadata": {
    "duration": 8,
    "resolution": "720p",
    "fps": 24,
    "aspectRatio": "16:9"
  }
}
```

#### 🛠️ Running the Project
```bash
# Set your API key
export GEMINI_API_KEY="your-api-key-here"

# Start Genkit DevUI
genkit start -- npx tsx --watch src/index.ts

# Access the UI at http://localhost:4000
```

#### ⚠️ Important Notes
- **BILLING REQUIRED**: Video generation is NOT free - every request costs money
- Video generation is asynchronous and requires polling (may take several minutes)
- Text-to-video (Veo 3): Fixed 8 seconds, 720p, 24fps
- Image-to-video (Veo 2): Variable 5-8 seconds, 720p, 30fps
- Video URLs are temporary and expire after 24 hours
- Not all API keys have access to Veo models by default
- Image-to-video requires a starting image in base64 format
- Veo 3 does NOT support image-to-video generation

---

## 🔧 Getting Started

1. Clone this repository
2. Navigate to your language-specific documentation (e.g., `docs/nodejs/gemini.md`)
3. Follow the detailed setup and implementation guides
4. Test scenarios using the provided prompts and examples

## 📝 Contributing

When adding new scenarios:
1. Update this README with the scenario details
2. Add comprehensive documentation to the appropriate language guide
3. Include working code examples and test results
4. Mark the status appropriately