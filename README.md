This is our Docker base image for Elixir-powered services.

It assumes the following things about your Elixir application:

  * A mix task called `start` is provided. It should start your application and not halt.
