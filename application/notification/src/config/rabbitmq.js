import amqplib from 'amqplib'
import { sendSlackMsg } from '../notification.js'

let channel, connection

// Source : https://sharmilas.medium.com/get-started-with-rabbitmq-in-node-js-1adb18d019d0
// RabbitMq implementing the asynchronous single-receiver pattern.
/**
 * Init RabbitMQ.
 *
 */
export const connectRabbitmq = async () => {
  try {
    connection = await amqplib.connect(`amqp://user:${process.env.RABBITMQ_PASSWORD}@rabbit-rabbitmq.default.svc.cluster.local`)
    channel = await connection.createChannel()
    await channel.assertQueue('queue')
    console.log('RabbitMQ Notification SVC Connected!')
  } catch (error) {
    console.log(error)
  }
}

/**
 * Dequeue msg from RabbitMQ message broker queue.
 *
 */
export const consumeData = async () => {
  try {
    await channel.assertQueue('queue')

    // consume msg from queue.
    channel.consume('queue', async data => {
      await sendSlackMsg(`${Buffer.from(data.content)}`)

      await channel.ack(data)
    })
  } catch (error) {
    console.error(error)
  }
}
