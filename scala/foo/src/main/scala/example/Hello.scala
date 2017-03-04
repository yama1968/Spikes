package example

object Hello extends Greeting with App {
  println(greeting)
  println("That's done!!!!")
}

trait Greeting {
  lazy val greeting: String = "hello, world!!"
}
