import Dependencies._

lazy val coucou = taskKey[Unit]("Mon exemple de tâche")

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.example",
      scalaVersion := "2.12.1",
      version      := "0.1.0-SNAPSHOT"
    )),
    coucou := { println("Coucou!!!") },
    name := "Hello",
    libraryDependencies += scalaTest % Test
  )
