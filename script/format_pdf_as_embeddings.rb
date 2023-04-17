require 'pdf-reader'
require 'words_counted'
require 'httparty'
require 'csv'

def count_tokens(text)
  WordsCounted.count(text).token_count
end
def extract_pages(page_text, index)
  return [] if page_text.empty?

  content = page_text.split.join(' ')
  puts "page text: #{content}"
  outputs = [["Page #{index}", content, count_tokens(content) + 4]]

  outputs
end

pdf_file_name = ARGV[0]
filename = "#{pdf_file_name}"

reader = PDF::Reader.new(filename)

res = []
i = 1
reader.pages.each do |page|
  res += extract_pages(page.text, i)
  i += 1
end

# Filter out rows with tokens greater than or equal to 2046
filtered_res = res.reject { |row| row[2] >= 2046 }

# Write the filtered results to a CSV file
CSV.open("#{filename}.pages.csv", 'wb') do |csv|
  csv << ['title', 'content', 'tokens']
  filtered_res.each { |row| csv << row }
end

def get_embedding(text, model)
  openai_api_key = ENV['OPEN_AI_API_KEY']
  response = HTTParty.post(
    'https://api.openai.com/v1/embeddings',
    headers: { 'Authorization' => "Bearer #{openai_api_key}", 'Content-Type' => 'application/json' },
    body: { 'model': model, 'input': text }.to_json
  )
  puts response
  response['data'][0]['embedding']
end

def get_doc_embedding(text)
  model_name = 'curie'
  get_embedding(text, "text-search-#{model_name}-doc-001")
end

def compute_doc_embeddings(data)
  embeddings = {}
  data.each_with_index do |row, idx|
    content = row[1]
    embeddings[idx] = get_doc_embedding(content)
  end
  embeddings
end

doc_embeddings = compute_doc_embeddings(filtered_res)

CSV.open("#{filename}.embeddings.csv", 'wb') do |csv|
  csv << ['title'] + (0...4096).to_a
  doc_embeddings.each do |i, embedding|
    csv << ["Page #{i + 1}"] + embedding
  end
end