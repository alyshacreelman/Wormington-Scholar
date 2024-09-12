import gradio as gr
from huggingface_hub import InferenceClient
import torch
from transformers import pipeline

# Inference client setup
client = InferenceClient("HuggingFaceH4/zephyr-7b-beta")
pipe = pipeline("text-generation", "microsoft/Phi-3-mini-4k-instruct", torch_dtype=torch.bfloat16, device_map="auto")

# Global flag to handle cancellation
stop_inference = False


def respond(
    message,
    history: list[tuple[str, str]],
    system_message="You are a friendly Chatbot.",
    max_tokens=512,
    temperature=1.5,
    top_p=0.95,
    use_local_model=False,
):
    global stop_inference
    stop_inference = False  # Reset cancellation flag

    # Initialize history if it's None
    if history is None:
        history = []

    if use_local_model:
        # local inference 
        messages = [{"role": "system", "content": system_message}]
        for val in history:
            if val[0]:
                messages.append({"role": "user", "content": val[0]})
            if val[1]:
                messages.append({"role": "assistant", "content": val[1]})
        messages.append({"role": "user", "content": message})

        response = ""
        for output in pipe(
            messages,
            max_new_tokens=max_tokens,
            temperature=temperature,
            do_sample=True,
            top_p=top_p,
        ):
            if stop_inference:
                response = "Inference cancelled."
                yield history + [(message, response)]
                return
            token = output['generated_text'][-1]['content']
            response += token
            yield history + [(message, response)]  # Yield history + new response

    else:
        # API-based inference 
        messages = [{"role": "system", "content": system_message}]
        for val in history:
            if val[0]:
                messages.append({"role": "user", "content": val[0]})
            if val[1]:
                messages.append({"role": "assistant", "content": val[1]})
        messages.append({"role": "user", "content": message})

        response = ""
        for message_chunk in client.chat_completion(
            messages,
            max_tokens=max_tokens,
            stream=True,
            temperature=temperature,
            top_p=top_p,
        ):
            if stop_inference:
                response = "Inference cancelled."
                yield history + [(message, response)]
                return
            if stop_inference:
                response = "Inference cancelled."
                break
            token = message_chunk.choices[0].delta.content
            response += token
            yield history + [(message, response)]  # Yield history + new response


def cancel_inference():
    global stop_inference
    stop_inference = True

# Custom CSS for a fancy look
custom_css = """
#main-container {
    background: #cdebc5;
    font-family: 'Comic Neue', sans-serif;
}

.gradio-container {
    max-width: 700px;
    margin: 0 auto;
    padding: 20px;
    background: #cdebc5;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    border-radius: 10px;
}

.gr-button {
    background-color: #a7e0fd;
    color: light blue;
    border: none;
    border-radius: 5px;
    padding: 10px 20px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.gr-button:hover {
    background-color: #45a049;
}

.gr-slider input {
    color: #4CAF50;
}

.gr-chat {
    font-size: 16px;
}

#title {
    text-align: center;
    font-size: 2em;
    margin-bottom: 20px;
    color: #a7e0fd;
}
"""


# Define the interface
with gr.Blocks(css=custom_css) as demo:
    gr.Markdown("<h2 style='text-align: center;'>🍎✏️ School AI Chatbot ✏️🍎</h2>")
    gr.Markdown("<h1 style='text-align: center;'>🐛</h1>")
    gr.Markdown("Interact with Wormington Scholar 🐛 by selecting the appropriate level below.")


    
    with gr.Row():
        system_message = gr.Dropdown(
            choices=["You are a friendly Chatbot that responds with the vocabulary of the seven year old.", 
                     "You are a friendly Chatbot. Please respond at a level that middle schoolers can understand", 
                     "You are a friendly high school Chatbot who responds at a level the average person can understand.", 
                     "You are a friendly Chatbot that uses a very advanced, college-level vocabulary in your responses."],
            label="System message",
            interactive=True
        )

    with gr.Row():  
        use_local_model = gr.Checkbox(label="Use Local Model", value=False)
    

    with gr.Row():
        max_tokens = gr.Slider(minimum=1, maximum=2048, value=512, step=1, label="Max new tokens")
        temperature = gr.Slider(minimum=0.5, maximum=4.0, value=1.2, step=0.1, label="Temperature")
        top_p = gr.Slider(minimum=0.1, maximum=1.0, value=0.95, step=0.05, label="Top-p (nucleus sampling)")

    chat_history = gr.Chatbot(label="Chat")

    user_input = gr.Textbox(show_label=False, placeholder="Type your message here...")

    cancel_button = gr.Button("Cancel Inference", variant="danger")

    # Adjusted to ensure history is maintained and passed correctly
    user_input.submit(respond, [user_input, chat_history, system_message, max_tokens, temperature, top_p, use_local_model], chat_history)

    cancel_button.click(cancel_inference)



if __name__ == "__main__":
    demo.launch(share=False)  # Remove share=True because it's not supported on HF Spaces