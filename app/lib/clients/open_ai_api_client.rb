class OpenAIApiClient

  COMPLETIONS_API_PARAMS = {
    temperature: 0.0,
    max_tokens: 150,
    model: 'text-davinci-003'
  }.freeze

  OPEN_AI_API_KEY = ENV["OPEN_AI_API_KEY"]

  def fetch_completions(prompt)
    puts "in fetch_completions_from_open_ai"

    # Prepare the API call headers
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{OPEN_AI_API_KEY}"
    }

    # Prepare the API call body
    body = {
      "model" => COMPLETIONS_API_PARAMS[:model],
      "prompt" => prompt,
      "max_tokens" => COMPLETIONS_API_PARAMS[:max_tokens],
      "temperature" => COMPLETIONS_API_PARAMS[:temperature]
    }.to_json

    # Make the API call
    response = HTTParty.post(
      "https://api.openai.com/v1/completions",
      headers: headers,
      body: body
    )

    puts response

    # Return the text response
    response['choices'][0]['text'].strip
  end

  def fetch_embeddings(text)
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{OPEN_AI_API_KEY}"
    }
    body = {
      "model" => "text-search-curie-doc-001",
      "input" => text
    }.to_json

    response = HTTParty.post(
      "https://api.openai.com/v1/embeddings",
      headers: headers,
      body: body
    )

    response["data"][0]["embedding"]
  end
end