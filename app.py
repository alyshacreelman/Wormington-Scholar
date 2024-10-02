import gradio as gr 
from huggingface_hub import InferenceClient
import torch
from transformers import pipeline
import os
import sys

if len(sys.argv) > 1:
    token = sys.argv[1]
else:
    token = os.getenv('HF_TOKEN')

print(token)

# Inference client setup with token from environment
# token = os.getenv('HF_TOKEN')
client = InferenceClient(model="HuggingFaceH4/zephyr-7b-alpha", token=token, stream=False)
# pipe = pipeline("text-generation", "TinyLlama/TinyLlama_v1.1", torch_dtype=torch.bfloat16, device_map="auto")
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
            stream=False,
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
            token = message_chunk.choices[0].delta.content
            response += token
            yield history + [(message, response)]  # Yield history + new response


def cancel_inference():
    global stop_inference
    stop_inference = True

# Custom CSS to disable buttons visually
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
.gr-button:disabled {
    background-color: grey;
    cursor: not-allowed;
}
"""

# Define system messages for each level
def update_system_message(level):
    if level == "Elementary School":
        return "Your name is Wormington. You are a friendly Chatbot that can help answer questions from elementary school students. Please respond with the vocabulary that a seven-year-old can understand."
    elif level == "Middle School":
        return "Your name is Wormington. You are a friendly Chatbot that can help answer questions from middle school students. Please respond at a level that middle schoolers can understand."
    elif level == "High School":
        return "Your name is Wormington. You are a friendly Chatbot that can help answer questions from high school students. Please respond at a level that a high schooler can understand."
    elif level == "College":
        return "Your name is Wormington. You are a friendly Chatbot that can help answer questions from college students. Please respond using very advanced, college-level vocabulary."

# Disable all buttons after one is clicked
def disable_buttons_and_update_message(level):
    system_message = update_system_message(level)
    # Update button states to disabled
    return system_message, gr.update(interactive=False), gr.update(interactive=False), gr.update(interactive=False), gr.update(interactive=False)

# Restart function to refresh the app
def restart_chatbot():
    # Reset buttons and clear system message display
    return gr.update(value="", interactive=True), gr.update(interactive=True), gr.update(interactive=True), gr.update(interactive=True), gr.update(interactive=True)

# Define interface
with gr.Blocks(css=custom_css) as demo:
    gr.Markdown("<h2 style='text-align: center;'>🍎✏️ School AI Chatbot ✏️🍎</h2>")
    gr.Markdown("<h1 style= 'text-align: center;'>Interact with Wormington Scholar 🐛 by selecting the appropriate level below!</h1>")

    with gr.Row():
        elementary_button = gr.Button("Elementary School", elem_id="elementary", variant="primary")
        middle_button = gr.Button("Middle School", elem_id="middle", variant="primary")
        high_button = gr.Button("High School", elem_id="high", variant="primary")
        college_button = gr.Button("College", elem_id="college", variant="primary")

    # Display area for the selected system message
    system_message_display = gr.Textbox(label="System Message", value="", interactive=False)

    # Disable buttons and update the system message when a button is clicked
    elementary_button.click(fn=lambda: disable_buttons_and_update_message("Elementary School"), 
                            inputs=None, 
                            outputs=[system_message_display, elementary_button, middle_button, high_button, college_button])
    
    middle_button.click(fn=lambda: disable_buttons_and_update_message("Middle School"), 
                        inputs=None, 
                        outputs=[system_message_display, elementary_button, middle_button, high_button, college_button])
    
    high_button.click(fn=lambda: disable_buttons_and_update_message("High School"), 
                      inputs=None, 
                      outputs=[system_message_display, elementary_button, middle_button, high_button, college_button])
    
    college_button.click(fn=lambda: disable_buttons_and_update_message("College"), 
                         inputs=None, 
                         outputs=[system_message_display, elementary_button, middle_button, high_button, college_button])

    with gr.Row():  
        use_local_model = gr.Checkbox(label="Use Local Model", value=False)

    with gr.Row():
        max_tokens = gr.Slider(minimum=1, maximum=2048, value=512, step=1, label="Max new tokens")
        temperature = gr.Slider(minimum=0.5, maximum=4.0, value=1.2, step=0.1, label="Temperature")
        top_p = gr.Slider(minimum=0.1, maximum=1.0, value=0.95, step=0.05, label="Top-p (nucleus sampling)")

    chat_history = gr.Chatbot(label="Chat")

    user_input = gr.Textbox(show_label=False, placeholder="Wormington would love to answer your questions. Type them here:")

    cancel_button = gr.Button("Cancel Inference", variant="danger")
    restart_button = gr.Button("Restart Chatbot", variant="secondary")

    # Adjusted to ensure history is maintained and passed correctly
    user_input.submit(respond, [user_input, chat_history, system_message_display, max_tokens, temperature, top_p, use_local_model], chat_history)

    cancel_button.click(cancel_inference)

    # Reset the buttons when the "Restart Chatbot" button is clicked
    restart_button.click(fn=restart_chatbot, 
                         inputs=None, 
                         outputs=[system_message_display, elementary_button, middle_button, high_button, college_button])

if __name__ == "__main__":
    demo.launch(share=False)
