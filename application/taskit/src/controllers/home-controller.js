/**
 * Home controller.
 *
 * @author Mats Loock
 * @version 2.0.0
 */

import { readRedisStore } from '../config/redis.js'

/**
 * Encapsulates a controller.
 */
export class HomeController {
  /**
   * Renders a view and sends the rendered HTML string as an HTTP response.
   * index GET.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   * @param {Function} next - Express next middleware function.
   */
  async index (req, res, next) {
    const redisUser = await readRedisStore()
    res.render('home/index', { user: redisUser })
  }
}
