// Code based on : https://thecodebarbarian.com/working-with-the-slack-api-in-node-js.html
import axios from 'axios'

/**
 * Dequeue msg from RabbitMQ and send to slack.
 *
 * @param {string} msg The message to send to Slack channel.
 */
export async function sendSlackMsg (msg) {
  try {
    const url = 'https://slack.com/api/chat.postMessage'
    await axios.post(url, {
      channel: process.env.SLACKCHANNEL,
      text: msg
    }, { headers: { authorization: `Bearer ${process.env.SLACKACCESSTOKEN}` } })
  } catch (err) {
    console.error(err)
  }
}
