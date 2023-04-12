import * as React from "react";

interface AskQuestionProps {
    // Add any props you need for this component.
}

const AskQuestion: React.FC<AskQuestionProps> = () => {
    const [question, setQuestion] = React.useState("");
    const [response, setResponse] = React.useState("");

    const handleSubmit = async () => {
        // Handle the question submission here.
        // For now, we just set the response to the submitted question.
        setResponse(question);
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
