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
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", minHeight: "100vh", fontFamily: "Arial, sans-serif" }}>
            <h1>Ask a question</h1>
            <div style={{ display: "flex", flexDirection: "column", alignItems: "center", width: "50%" }}>
                <textarea
                    value={question}
                    onChange={(e) => setQuestion(e.target.value)}
                    placeholder="Ask a question..."
                    style={{ width: "100%", height: "150px", fontSize: "18px", padding: "10px", borderRadius: "4px", border: "1px solid #ccc" }}
                />
                <button onClick={handleSubmit} style={{
                    backgroundColor: "#007BFF",
                    color: "white",
                    borderRadius: "4px",
                    border: "none",
                    padding: "10px 20px",
                    fontSize: "18px",
                    marginTop: "10px",
                    cursor: "pointer",
                    transition: "0.3s",
                }}>
                    Submit
                </button>
                {response && <div style={{ marginTop: "20px" }}>Response: {response}</div>}
            </div>
        </div>
    );
};

export default AskQuestion;