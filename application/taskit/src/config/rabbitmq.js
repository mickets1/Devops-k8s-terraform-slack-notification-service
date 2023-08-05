import amqplib from 'amqplib'

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
    console.log('RabbitMQ Taskit SVC Connected!')
  } catch (error) {
    console.log(error)
  }
}

/**
 * Send msg to RabbitMQ message broker queue.
 *
 * @param {string} data the msg string.
 */
export const sendData = async (data) => {
  await channel.sendToQueue('queue', Buffer.from(JSON.stringify(data)))
}
