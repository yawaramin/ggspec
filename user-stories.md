# User Stories

  + As a test writer
  - So that I can easily set up `ggspec` to interoperate with other
    tools in my workflow
  - I want to pass command line options into a `ggspec` test runner

    + As a test writer
    - So that I can run a full set of tests easily
    - I want a test runner command that looks inside a given directory
      and all its subdirectories and runs all tests found therein.

  + As a test reader
  - So that I can focus on failing tests more quickly
  - I want the default test output to show details of a test and its
    assertions _only if the test fails._

  + As a test writer
  - So that I can test for more kinds of scenarios
  - I want `assert-error` and `assert-not-error` functions to check that
    a piece of code does or does not cause an error to occur.

  + As a test writer
  - So that I can use the framework more easily
  - I want to be able to use ggspec straight from its git cloned
    repository directory without having to manipulate any environment
    variables.

