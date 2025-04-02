// cSpell:words siliconflow deepseek qwen rerank reranker baai bgem

/* Fetch Secrets */

// @ts-ignore - can't find type definitions here
import { execSync } from "node:child_process";

const fetchKey = (path: string): string => {
  return execSync(`op read op://${path}`, { encoding: "utf8" }).trim();
};

const siliconFlowKey = fetchKey("dev/silicon-flow/continue");
const voyageKey = fetchKey("dev/voyage-ai/credential");
const anthropicKey = fetchKey("dev/anthropic/continue");
const openAIKey = fetchKey("dev/openai/continue");

/* Model Definitions */

const prompt =
  "You are an expert software developer. You give helpful and concise responses.";

/* Chat Models */

const SiliconFlow: Partial<ModelDescription> & { provider: string } = {
  provider: "siliconflow",
  apiKey: siliconFlowKey,
};

const DSV3: ModelDescription = {
  ...SiliconFlow,
  title: "DeepSeek V3",
  model: "deepseek-ai/DeepSeek-V3",
  systemMessage: prompt,
};

const DSV3Pro: ModelDescription = {
  ...SiliconFlow,
  title: "DeepSeek V3 - Pro",
  model: "Pro/deepseek-ai/DeepSeek-V3",
  systemMessage: prompt,
};

const DSR1: ModelDescription = {
  ...SiliconFlow,
  title: "DeepSeek R1",
  model: "deepseek-ai/DeepSeek-R1",
  systemMessage: prompt,
};

const DSR1Pro: ModelDescription = {
  ...SiliconFlow,
  title: "DeepSeek R1 - Pro",
  model: "Pro/deepseek-ai/DeepSeek-R1",
  systemMessage: prompt,
};

const DSV25: ModelDescription = {
  ...SiliconFlow,
  title: "DeepSeek V2.5",
  model: "deepseek-ai/DeepSeek-V2.5",
};

const Qwen25: ModelDescription = {
  ...SiliconFlow,
  title: "Qwen 2.5 Coder",
  model: "Qwen/Qwen2.5-Coder-32B-Instruct",
};

const Sonnet: ModelDescription = {
  title: "Claude 3.7 Sonnet",
  provider: "anthropic",
  model: "claude-3-7-sonnet-latest",
  apiKey: anthropicKey,
  systemMessage: prompt,
  cacheBehavior: {
    cacheSystemMessage: true,
    cacheConversation: true,
  },
};

const GPT4o: ModelDescription = {
  title: "GPT-4o",
  provider: "openai",
  model: "gpt-4o",
  apiKey: openAIKey,
};

/* Embeddings Provider */

const BGEM3: EmbeddingsProviderDescription = {
  ...SiliconFlow,
  model: "BAAI/bge-m3",
};

const VoyageCode3: EmbeddingsProviderDescription = {
  provider: "voyage",
  model: "voyage-code-3",
  apiKey: voyageKey,
};

/* Reranker */

const BGERerankerV2M3: RerankerDescription = {
  name: "siliconflow",
  params: {
    model: "BAAI/reranker-v2-m3",
    apiKey: siliconFlowKey,
  },
};

const VoyageRerank2: RerankerDescription = {
  name: "voyage",
  params: {
    model: "rerank-2",
    apiKey: voyageKey,
  },
};

export function modifyConfig(config: Config): Config {
  [DSV3, DSR1, DSV3Pro, DSR1Pro, Sonnet, GPT4o].forEach((model) =>
    config.models.push(model),
  );
  config.tabAutocompleteModel = Qwen25;
  config.embeddingsProvider = BGEM3;
  config.reranker = VoyageRerank2;
  return config;
}
