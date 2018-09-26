module SGD(examples[10000000][100], gradient: x[100] -> y[100]) {
  import random

  weights = [1...100] { 0 }
  rate = 1

  [1...1_000_000_000] {
    weights -= weights * rate * gradient(examples[random.integer(0,10000000)], weights)
    rate *= 0.999999
  }

  weights
}
