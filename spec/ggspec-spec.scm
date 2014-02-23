#!
ggspec-spec.scm - 'white box' tests for the 'ggspec' script. Because of
Scheme's flexibility in loading code in different ways, we can do full
white box testing (i.e., complete testing of a module's internals) by
just loading the file with 'primitive-load'.

Copyright (c) 2014 Yawar Amin
GitHub, Reddit, Twitter: yawaramin

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
!#
(primitive-load-path "ggspec")

(suite "The get-rc function"
  (tests
    (test
      "Should return an empty list if a ~/.ggspecrc file does not exist or is empty"
      e
      (assert-equal
        end
        (stub
          '(ggspec lib)
          'call-with-input-file
          (lambda (fname proc) (call-with-input-string "" proc))
          (get-rc))))
    (test "Should return a non-empty list if the rc file exists and contains options"
      e
      (assert-equal
        (list "-c" "--format" "tap")
        (stub
          '(ggspec lib)
          'call-with-input-file
          (lambda (fname proc)
            (call-with-input-string "-c\n--format tap\n" proc))
          (get-rc))))))

