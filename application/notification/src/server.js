import express from 'express'
import { connectRabbitmq, consumeData } from './config/rabbitmq.js'

try {
  const app = express()

  // RabbitMQ
  await connectRabbitmq()
  await consumeData()

  // Starts the HTTP server listening for connections.
  app.listen(process.env.PORT, () => {
    console.log(`Server running at http://localhost:${process.env.PORT}`)
    console.log('Press Ctrl-C to terminate...')
  })
} catch (err) {
  console.error(err)
}
