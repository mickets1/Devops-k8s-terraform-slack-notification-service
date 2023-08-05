import { createClient } from 'redis'

let client

/**
 * Init and set student id from env.
 *
 * @returns {object} Redis client object.
 */
export async function redis () {
  client = createClient({
    url: 'redis://default:secretpassword@redis-master.default.svc.cluster.local:6379',
    legacyMode: true
  })
  client.on('error', (err) => console.log('Redis Client Error', err))

  await client.connect()

  await client.v4.set('user', process.env.STUDENTID)

  return client
}

/**
 * Get student id from Redis store.
 *
 * @returns {string} redis student id string from store.
 */
export async function readRedisStore () {
  return await client.v4.get('user')
}
