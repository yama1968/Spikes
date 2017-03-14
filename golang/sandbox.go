package main

import (
  "fmt"
  "time"
  "math/rand"
)

func fact(n int) int {
  if (n <= 1) {
    return 1
  } else {
    return n * fact(n-1)
  }
}

func main() {
  fmt.Println("Welcome to the playground!")
  fmt.Println("The time is", time.Now())
  fmt.Println("My fav number is", rand.Intn(10))
  fmt.Println("fact(20) = ", fact(20))
}
