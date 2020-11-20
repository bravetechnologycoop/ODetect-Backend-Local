// Third-party dependencies
const express = require('express')
const http = require('http')
const socket = require('socket.io')

// In-house dependencies
const db = require('./db/db.js')

// Setup Socket
const app = express()
const io = socket(http.Server(app))

class IoSocketConfigurator {
    constructor(locations) {
        this.locations = locations
        
        // Web Socket connection to Frontend
        io.on('connection', this.onConnection.bind(this))
    }

    onConnection(socket) {
        socket.on('getHistory', async (location, entries) => {
            let sessionHistory = await db.getHistoryOfSessions(location, entries)
            io.sockets.emit('sendHistory', {data: sessionHistory})
        })

        socket.emit('getLocations', {
            data: this.locations
        })
        
        socket.emit('Hello', {
            greeting: "Hello ODetect Frontend"
        })
    }

    // Sends currentSession data with end_time which will close the session in the frontend
    emitSessionData(session) {
        io.sockets.emit('sessiondata', {data: session})
    }

    emitGetLocations(locationsArray) {
        io.sockets.emit('getLocations', {data: locationsArray})
    }

    listen(server) {
        io.listen(server)
    }
}

module.exports = IoSocketConfigurator
