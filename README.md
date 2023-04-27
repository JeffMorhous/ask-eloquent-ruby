# README

## Overview

### Vector Embedding Script

There is a ruby script, `script/format_pdf_as_embeddings.rb` that
formats a PDF manuscript as a csv of embeddings.

You can run it with:

```bash
bundle install
```

```bash
ruby script/format_pdf_as_embeddings.rb <path-to-pdf>
```

It will output a csv that has each page's number, content, and number of tokens.
Then it will output a file that has each page's content as a vector embedding.

This application includes the Eloquent Ruby, but it can be abstracted to other books.

### Application

The application is Ruby on Rails with React on the frontend.

There is only one component, `app/javascript/components/AskQuestion.tsx`,
and it contains a textbox for a button. When the button is clicked, the text
is sent to the backend and the response is rendered underneath the button.

There is only one controller, `app/controllers/questions_controller.rb`, and it
contains a single action: `ask`.

Ask takes the question from the params, and sends it to the `QuestionService`

`QuestionService` handles most of the actual logic of gathering the relevant context
and constructing a prompt. It then calls the Open AI API with the `app/lib/clients/open_ai_api_client.rb`
class that I built.

## Learnings & What I Would Do Differently

I'm not super confident in the `order_document_sections_by_query_similarity` method that I've written.
The application generally gives correct answers but evaluating constructed prompts it seems that the
context it is choosing to include is not always relevant to the query.

If I did this again, I would have started with unit tests for that class and TDD'd the whole thing
to build confidence along the way.

This was a really challenging project and I've learned a lot about vector embeddings along the way,
and I'll definitely be refining this project moving forward.

## Developing Locally

First, you'll need to set the environment variable:

```bash
export OPEN_AI_API_KEY=<your-open-ai-api-key>
```

Then, install dependencies:

```bash
bundle install
```
You can then run the application locally with:

```bash
bin/dev
```

Then, visit `localhost:3000` in your browser