/**
 * Module for the TasksController.
 *
 * @author Mats Loock
 * @version 2.0.0
 */

import { sendData } from '../config/rabbitmq.js'
import { readRedisStore } from '../config/redis.js'
import { Task } from '../models/task.js'

/**
 * Encapsulates a controller.
 */
export class TasksController {
  /**
   * Displays a list of tasks.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   * @param {Function} next - Express next middleware function.
   */
  async index (req, res, next) {
    try {
      const viewData = {
        tasks: (await Task.find())
          .map(task => task.toObject())
      }

      res.render('tasks/index', { viewData })
    } catch (error) {
      next(error)
    }
  }

  /**
   * Returns a HTML form for creating a new task.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   */
  async create (req, res) {
    res.render('tasks/create')
  }

  /**
   * Creates a new task.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   */
  async createPost (req, res) {
    try {
      const task = new Task({
        description: req.body.description,
        sessionId: req.session.id
      })

      await task.save()

      sendData(`${task.description} created by ${await readRedisStore()}`)

      req.session.flash = { type: 'success', text: 'The task was created successfully.' }
      res.redirect('.')
    } catch (error) {
      req.session.flash = { type: 'danger', text: error.message }
      res.redirect('./create')
    }
  }

  /**
   * Returns a HTML form for updating a task.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   */
  async update (req, res) {
    try {
      const task = await Task.findById(req.params.id)

      res.render('tasks/update', { viewData: task.toObject() })
    } catch (error) {
      req.session.flash = { type: 'danger', text: error.message }
      res.redirect('..')
    }
  }

  /**
   * Updates a specific task.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   */
  async updatePost (req, res) {
    try {
      const task = await Task.findById(req.params.id)

      if (task) {
        task.description = req.body.description
        task.done = req.body.done === 'on'

        await task.save()

        if (req.body.done === 'on') {
          sendData(`${task.description} completed by ${await readRedisStore()}`)
        } else {
          sendData(`${task.description} uncompleted by ${await readRedisStore()}`)
        }

        req.session.flash = { type: 'success', text: 'The task was updated successfully.' }
      } else {
        req.session.flash = {
          type: 'danger',
          text: 'The task you attempted to update was removed by another user after you got the original values.'
        }
      }
      res.redirect('..')
    } catch (error) {
      req.session.flash = { type: 'danger', text: error.message }
      res.redirect('./update')
    }
  }

  /**
   * Returns a HTML form for deleting a task.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   */
  async delete (req, res) {
    try {
      const task = await Task.findById(req.params.id)

      res.render('tasks/delete', { viewData: task.toObject() })
    } catch (error) {
      req.session.flash = { type: 'danger', text: error.message }
      res.redirect('..')
    }
  }

  /**
   * Deletes the specified task.
   *
   * @param {object} req - Express request object.
   * @param {object} res - Express response object.
   */
  async deletePost (req, res) {
    try {
      const task = await Task.findByIdAndDelete(req.body.id)

      if (task) {
        sendData(`${task.description} deleted by ${await readRedisStore()}`)
      }

      req.session.flash = { type: 'success', text: 'The task was deleted successfully.' }
      res.redirect('..')
    } catch (error) {
      req.session.flash = { type: 'danger', text: error.message }
      res.redirect('./delete')
    }
  }
}
