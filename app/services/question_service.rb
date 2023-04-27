require 'httparty'
require_relative '../lib/clients/open_ai_api_client'

class QuestionService

  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "

  def initialize
    @openai_api_client = OpenAIApiClient.new
  end

  def answer(question_text)
    question_text += '?' unless question_text[-1] == '?'

    question = Question.find_or_create_by(question_text: question_text)
    return "Sorry, there was a problem saving your question" unless question.persisted?
    return question.answer if question.answer.present?

    begin
      # Load the data from the CSV files
      df = CSV.read('files/eloquent-ruby.pdf.pages.csv', headers: true)

      answer, context = answer_query_with_context(question_text, df, document_embeddings)
      question.context = context
      question.answer = answer
      question.save

      return answer
    rescue OpenAIApiClient::ApiError => e
      return "Sorry, there was a problem getting data from Open AI"
    end
  end

  private

  def document_embeddings
    @document_embeddings ||= load_embeddings('files/eloquent-ruby.pdf.embeddings.csv')
  end

  def load_embeddings(file_path)
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
    prompt, context = construct_prompt(query, document_embeddings, df)

    # Make an API call to OpenAI with the constructed prompt
    response = @openai_api_client.fetch_completions(prompt)

    return [response, context]
  end

  def construct_prompt(question, context_embeddings, df)
    most_relevant_document_sections = order_document_sections_by_query_similarity(question, context_embeddings)

    chosen_sections = []
    chosen_sections_len = 0
    chosen_sections_indexes = []

    most_relevant_document_sections.each do |_, section_index|
      document_section = df.find { |row| row['title'] == section_index }

      chosen_sections_len += document_section["tokens"].to_i + SEPARATOR.length
      if chosen_sections_len > MAX_SECTION_LEN
        chosen_sections.append(SEPARATOR + document_section["content"])
        chosen_sections_indexes.append(section_index.to_s)
        break
      end

      chosen_sections.append(SEPARATOR + document_section["content"])
      chosen_sections_indexes.append(section_index.to_s)
    end

    header =  "Russ Olsen is a Ruby programmer and the author of the book Eloquent Ruby. These are questions and answers by him. " \
              "Speak in complete sentences. Do not repeat the question. " \
              "When asked a question about how to program something, give answers as Russ Olsen would in Eloquent Ruby."
              "Answer questions knowing that there are often many ways to do things in Ruby, and choose the most conventional way. "
              "Context that may be useful, pulled from Eloquent Ruby:\n"

    predefined_questions =
      "\n\nQ: How do I write code that looks like Ruby?\n\nA: More than anything else, code that looks like Ruby looks readable. " \
      "This means that although Ruby programmers generally follow the coding conventions" \
      "\nQ: What is the difference between unless and if?\n\nA: With unless, the body of the statement is executed only if the " \
      "condition is false. The unless-based version of title= has two advantages: First, it is exactly one token (the not) shorter " \
      "than the if not rendition. Second—and much more important— is that once you get used to it, the unless-based decision takes " \
      "less mental energy to read and understand."

    prompt = header + chosen_sections.join + predefined_questions + "\n\n\nQ: " + question + "\n\nA: "
    [prompt, chosen_sections.join]
  end

  def order_document_sections_by_query_similarity(query, document_embeddings)
    query_embedding = @openai_api_client.fetch_embeddings(query)

    document_similarities = document_embeddings.map do |doc_index, doc_embedding|
      [vector_similarity(query_embedding, doc_embedding), doc_index]
    end

    # Sort the document_similarities in descending order
    document_similarities.sort { |a, b| b[0] <=> a[0] }
  end

  def vector_similarity(x, y)
    dot_product = 0
    x.zip(y).each do |v1i, v2i|
      dot_product += v1i * v2i
    end
    a = x.map { |n| n ** 2 }.reduce(:+)
    b = y.map { |n| n ** 2 }.reduce(:+)
    return dot_product / (Math.sqrt(a) * Math.sqrt(b))
  end
end
