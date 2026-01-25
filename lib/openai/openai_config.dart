// OpenAI/OpenRouter proxy configuration
// Values are provided at runtime via environment variables.
// Do NOT append paths like 'v1/chat/completions' here; the endpoint should already be the full URL.
const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');
