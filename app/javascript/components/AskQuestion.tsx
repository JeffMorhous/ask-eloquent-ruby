import * as React from "react";

interface AskQuestionProps {
    // Add any props you need for this component.
}

const AskQuestion: React.FC<AskQuestionProps> = () => {
    const [question, setQuestion] = React.useState("");
    const [response, setResponse] = React.useState("");

    const handleSubmit = async () => {
        try {
            const result = await fetch("/questions/ask", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.getElementsByName("csrf-token")[0].getAttribute("content"),
                },
                body: JSON.stringify({ question }),
            });
            const data = await result.json();
            setResponse(data.response);
        } catch (error) {
            console.error("Error:", error);
        }
    };

    return (
        <div>
      <textarea
          value={question}
          onChange={(e) => setQuestion(e.target.value)}
          placeholder="Ask a question..."
      />
            <button onClick={handleSubmit}>Submit</button>
            {response && <div>Response: {response}</div>}
        </div>
    );
};

export default AskQuestion;