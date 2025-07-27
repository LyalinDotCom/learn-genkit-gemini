#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# Clear screen for better presentation
clear

# ASCII Art Header
echo -e "${CYAN}"
echo "   ██████╗ ███████╗███╗   ██╗██╗  ██╗██╗████████╗"
echo "  ██╔════╝ ██╔════╝████╗  ██║██║ ██╔╝██║╚══██╔══╝"
echo "  ██║  ███╗█████╗  ██╔██╗ ██║█████╔╝ ██║   ██║   "
echo "  ██║   ██║██╔══╝  ██║╚██╗██║██╔═██╗ ██║   ██║   "
echo "  ╚██████╔╝███████╗██║ ╚████║██║  ██╗██║   ██║   "
echo "   ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝   ╚═╝   "
echo -e "${NC}"
echo -e "${MAGENTA}        🤖 AI-Powered Development Framework 🤖${NC}"
echo ""
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}${BOLD}          Genkit + Gemini Examples Runner${NC}"
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════${NC}"
echo ""

# Check for --yolo flag
YOLO_MODE=false
if [[ "$1" == "--yolo" ]]; then
    YOLO_MODE=true
    echo -e "${RED}${BLINK}⚠️  YOLO MODE ACTIVATED ⚠️${NC}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}WARNING: All tool calls will be automatically approved!${NC}"
    echo -e "${YELLOW}This means Gemini CLI will:${NC}"
    echo -e "${YELLOW}  • Create files without confirmation${NC}"
    echo -e "${YELLOW}  • Install packages without asking${NC}"
    echo -e "${YELLOW}  • Execute commands automatically${NC}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${RED}Press Enter to continue in YOLO mode, or Ctrl+C to exit...${NC}"
    read -r
    echo ""
fi

# Check if gemini CLI is available
if ! command -v gemini &> /dev/null; then
    echo -e "${RED}Error: Gemini CLI is not installed!${NC}"
    echo ""
    echo -e "${YELLOW}To install Gemini CLI, run:${NC}"
    echo -e "${GREEN}npm install -g @genkit-ai/cli${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Gemini CLI is installed${NC}"
echo ""

# Define scenarios using regular arrays (compatible with older bash)
scenarios=()
prompts=()
descriptions=()

# Scenario 1: Basic Inference (Text Generation)
scenarios[1]="story-generation"
prompts[1]="I need a story writing app using Genkit. Users should be able to enter any topic and get back a creative story about it. Give them options for story length (short, medium, or long). Use Gemini AI to generate the stories."
descriptions[1]="✅ Basic Inference (Text Generation) - Story writing app"

# Scenario 2: Text-to-Speech Generation: Single Speaker
scenarios[2]="tts-single-speaker"
prompts[2]="Build me a project that uses Genkit on the backend to take input from the user, translate it to Spanish from English and create an audio file using text-to-speech to read back the spanish text by generating the audio file. Use Gemini models for both tasks."
descriptions[2]="🔊 Text-to-Speech Generation: Single Speaker"

# Scenario 3: Text-to-Speech Generation: Multi-Speaker
scenarios[3]="tts-multi-speaker"
prompts[3]="Build a Genkit app that creates podcast-style audio conversations. I want to write dialogue between two people and have the app generate audio where each person sounds different. For example: \"Host: Welcome!\" and \"Guest: Thanks!\" should have distinct voices. Use Gemini's text-to-speech."
descriptions[3]="🔊 Text-to-Speech Generation: Multi-Speaker"

# Scenario 4: Image Generation with Gemini Flash
scenarios[4]="image-gen-flash"
prompts[4]="I need an AI image generator using Genkit with Gemini Flash. Users should be able to type what they want to see (like \"a cat wearing a superhero cape\") and get back a generated image quickly. Use the Gemini Flash model for fast image generation."
descriptions[4]="🖼️ Image Generation with Gemini Flash (Free)"

# Scenario 5: High-Quality Image Generation with Imagen
scenarios[5]="image-gen-imagen"
prompts[5]="Build an image generator with Genkit using Google's Imagen 4 preview model. I want high-quality, professional images with style controls (like \"photorealistic\" or \"watercolor\"). Users should be able to generate multiple variations of their prompt."
descriptions[5]="🎨 High-Quality Image Generation with Imagen (Paid)"

# Scenario 6: Video Generation (Veo 3 & Veo 2)
scenarios[6]="video-generation"
prompts[6]="Build a video creation app with Genkit where users describe scenes in text and get AI-generated videos. Support both text-to-video and image-to-video generation. Include options for aspect ratio and negative prompts. Use Google's Veo 3 preview model for text-to-video and Veo 2 for image-to-video."
descriptions[6]="🎬 Video Generation (Veo 3 & Veo 2) - No Free Tier"

# Display menu
echo -e "${BOLD}Select an example to generate:${NC}"
echo ""

for i in {1..6}; do
    echo -e "${YELLOW}[$i]${NC} ${descriptions[$i]}"
    if [[ "${scenarios[$i]}" == "video-generation" ]]; then
        echo -e "    ${RED}⚠️  Warning: Requires billing account (no free tier)${NC}"
    elif [[ "${scenarios[$i]}" == "image-gen-imagen" ]]; then
        echo -e "    ${YELLOW}⚠️  Note: May require paid tier for Imagen access${NC}"
    fi
    echo ""
done

echo -e "${YELLOW}[0]${NC} Exit"
echo ""

# Get user selection
read -p "Enter your choice (0-6): " choice

if [[ "$choice" == "0" ]]; then
    echo -e "${GREEN}Exiting...${NC}"
    exit 0
fi

if [[ ! "${scenarios[$choice]}" ]]; then
    echo -e "${RED}Invalid selection!${NC}"
    exit 1
fi

# Get selected scenario details
selected_scenario="${scenarios[$choice]}"
selected_prompt="${prompts[$choice]}"
selected_description="${descriptions[$choice]}"

echo ""
echo -e "${BLUE}${BOLD}Selected:${NC} ${selected_description}"
echo ""

# Create folder with auto-increment
base_folder="genkit-learn-${selected_scenario}"
folder_name="$base_folder-001"
counter=1

while [ -d "$folder_name" ]; do
    counter=$((counter + 1))
    folder_name=$(printf "%s-%03d" "$base_folder" "$counter")
done

echo -e "${GREEN}Creating folder:${NC} $folder_name"
mkdir -p "$folder_name"

# Copy gemini.md to the new folder
echo -e "${GREEN}Copying gemini.md to project folder...${NC}"
cp "$PWD/docs/nodejs/gemini.md" "$folder_name/"

cd "$folder_name"

echo ""
echo -e "${BLUE}${BOLD}Running Gemini CLI...${NC}"
echo -e "${YELLOW}Prompt:${NC} \"$selected_prompt\""
if [ "$YOLO_MODE" = true ]; then
    echo -e "${RED}${BOLD}Mode: YOLO (auto-approve enabled)${NC}"
fi
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Run gemini CLI with the selected prompt
if [ "$YOLO_MODE" = true ]; then
    gemini -i "$selected_prompt" --yolo
else
    gemini -i "$selected_prompt"
fi

# After Gemini CLI exits, show the user how to navigate to the project
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✅ Project generated successfully!${NC}"
echo ""
echo -e "${YELLOW}To navigate to your project, run:${NC}"
echo -e "${CYAN}${BOLD}cd $folder_name${NC}"
echo ""
echo -e "${YELLOW}To start the Genkit dev server:${NC}"
echo -e "${CYAN}${BOLD}cd $folder_name && npm run dev${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"