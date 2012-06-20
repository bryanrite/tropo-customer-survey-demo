# Tropo Customer Survey

A voice based customer survey application that calls a number, asks questions, and collects the responses via Tropo's WebAPI.

## Setup

The application has two pieces:

### Sinatra App

Run `bundle install` to get all the dependencies.

Copy `config/config.sample.yml` to `config/config.yml`.

You should be able to start the Sinatra app now by running `ruby application.rb`

Going to `http://localhost:4567` should display a welcome message and tell you that you have completed 0 surveys with 0 responses.

Make sure that this application is available to the internet as your Tropo application will need to send data to it.  Make note of its URL.

### Tropo App

A basic WebAPI tropo application has to be created.  Log into Tropo, create a WebAPI application, and set the callback URL to your Sinatra application: `http://your-sinatra-app.com/call_out.json`

Your newly created Tropo Application will have an associated Outbound Token, listed under the applications phone numbers.  Copy and paste this outbound token to the Sinatra applications config file.

## Usage

The Sinatra app communicates with Tropo to initiate the outbound call and manage the process of asking and storing surveys.

The `/` POST route is basic route for initializing a survey.  You can pass it an 11 digit telephone number to dial, and an array of questions to ask.  There is a `runner.rb` file that has an example of a basic survey (be sure to change the phone number to a real number).

Once you've changed the phone number to a valid one, you can see it in action with `ruby runner.rb`.

This will initiate a POST to your Sinatra App which in turn initiates an outbound call via Tropo.  We will ask and collect the responses to each of the questions asked and the results will be available via the GET `/results/:survey` route.

If you use runner, the URL you can check the results at will be displayed to you.
