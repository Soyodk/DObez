import gradio as gr
from huggingface_hub import InferenceClient

"""
Para mais informações sobre a API de Inferência da Hugging Face Hub:
https://huggingface.co/docs/huggingface_hub/v0.22.2/en/guides/inference
"""

# Instanciando dois clientes diferentes
client_zephyr = InferenceClient("HuggingFaceH4/zephyr-7b-beta")
client_deepseek = InferenceClient("deepseek-ai/DeepSeek-V3-0324")

def respond(
    message,
    history: list[tuple[str, str]],
    system_message,
    max_tokens,
    temperature,
    top_p,
    model_choice,
):
    # Escolhe o cliente conforme o modelo selecionado
    if model_choice == "Zephyr-7B-Beta":
        client = client_zephyr
    else:
        client = client_deepseek

    messages = [{"role": "system", "content": system_message}]
    for val in history:
        if val[0]:
            messages.append({"role": "user", "content": val[0]})
        if val[1]:
            messages.append({"role": "assistant", "content": val[1]})

    messages.append({"role": "user", "content": message})

    response = ""
    for message in client.chat_completion(
        messages,
        max_tokens=max_tokens,
        stream=True,
        temperature=temperature,
        top_p=top_p,
    ):
        token = message.choices[0].delta.content
        response += token
        yield response

"""
Para customizar o ChatInterface, veja:
https://www.gradio.app/docs/chatinterface
"""

demo = gr.ChatInterface(
    fn=respond,
    additional_inputs=[
        gr.Dropdown(
            choices=["Zephyr-7B-Beta", "DeepSeek-V3-0324"],
            value="Zephyr-7B-Beta",
            label="Escolha o Modelo"
        ),
        gr.Textbox(value="You are a friendly chatbot.", label="System Message"),
        gr.Slider(minimum=1, maximum=4096, value=512, step=1, label="Max New Tokens"),
        gr.Slider(minimum=0.1, maximum=4.0, value=0.7, step=0.1, label="Temperature"),
        gr.Slider(minimum=0.1, maximum=1.0, value=0.95, step=0.05, label="Top-p (nucleus sampling)"),
    ],
)

if __name__ == "__main__":
    demo.launch()
