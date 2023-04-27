require 'httparty'

class QuestionAnswerer

  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "

  COMPLETIONS_API_PARAMS = {
    temperature: 0.0,
    max_tokens: 150,
    model: 'text-davinci-003'
  }.freeze

  OPEN_AI_API_KEY = ENV["OPEN_AI_API_KEY"]

  def initialize(question)
    @question = question
  end

  def answer_question
    puts "in answer_question"

    # Load the data from the CSV files
    document_embeddings = load_embeddings('files/eloquent-ruby.pdf.embeddings.csv')
    df = CSV.read('files/eloquent-ruby.pdf.pages.csv', headers: true)

    # Call the OpenAI API to get the answer and context
    answer, context = answer_query_with_context(@question, df, document_embeddings) #Context will be saved with question in DB

    # Return the answer
    answer
  end

  private

  def load_embeddings(file_path)
    puts "in load_embeddings"

    embeddings = {}

    CSV.foreach(file_path, headers: true) do |row|
      title = row['title']
      max_dim = row.headers.select { |h| h =~ /^\d+$/ }.map(&:to_i).max
      embedding = (0..max_dim).map { |i| row[i.to_s].to_f }
      embeddings[title] = embedding
    end

    embeddings
  end

  def answer_query_with_context(query, df, document_embeddings)
    puts "in answer_query_with_context"

    prompt, context = construct_prompt(query, document_embeddings, df)

    # Make an API call to OpenAI with the constructed prompt
    response = fetch_completions_from_open_ai(prompt)

    return [response, context]
  end

  def construct_prompt(question, context_embeddings, df)
    puts "in construct_prompt"

    most_relevant_document_sections = order_document_sections_by_query_similarity(question, context_embeddings)

    chosen_sections = []
    chosen_sections_len = 0
    chosen_sections_indexes = []

    most_relevant_document_sections.each do |_, section_index|
      document_section = df.find { |row| row['title'] == section_index }

      chosen_sections_len += document_section["tokens"].to_i + SEPARATOR.length
      if chosen_sections_len > MAX_SECTION_LEN
        space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR.length
        chosen_sections.append(SEPARATOR + document_section["content"][0..space_left])
        chosen_sections_indexes.append(section_index.to_s)
        break
      end

      chosen_sections.append(SEPARATOR + document_section["content"])
      chosen_sections_indexes.append(section_index.to_s)
    end

    header =  "Russ Olsen is a Ruby programmer and the author of the book Eloquent Ruby. These are questions and answers by him. " \
              "Please keep your answers to three sentences maximum, and speak in complete sentences. Do not repeat the question. " \
              "Answer questions knowing that there are often many ways to do things in Ruby, and choose the most conventional way. "
              "Context that may be useful, pulled from Eloquent Ruby:\n"

    predefined_questions = [
      "\n\n\nQ: How do I write code that looks like Ruby?\n\nA: More than anything else, code that looks like Ruby looks readable. This means that although Ruby programmers generally follow the coding conventions",
    # Add the rest of the predefined questions here, similar to the one above
    ]

    prompt = header + chosen_sections.join + predefined_questions.join + "\n\n\nQ: " + question + "\n\nA: "
    [prompt, chosen_sections.join]
  end

  def order_document_sections_by_query_similarity(query, document_embeddings)
    puts "in order_document_sections_by_query_similarity"

    query_embedding = get_query_embedding(query)

    document_similarities = document_embeddings.map do |doc_index, doc_embedding|
      [vector_similarity(query_embedding, doc_embedding), doc_index]
    end

    # Sort the document_similarities in descending order
    document_similarities.sort { |a, b| b[0] <=> a[0] }
  end

  def get_query_embedding(text)
    puts "in get_query_embedding"

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

    puts response

    response["data"][0]["embedding"]
  end

  def vector_similarity(x, y)
    puts "in vector_similarity"

    x.zip(y).map { |xi, yi| xi * yi }.sum
  end

  def fetch_completions_from_open_ai(prompt)
    puts "in fetch_completions_from_open_ai"

    # Prepare the API call headers
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{OPEN_AI_API_KEY}"
    }
    debugger
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
end
