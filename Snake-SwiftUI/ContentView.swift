//
//  ContentView.swift
//  Snake-SwiftUI
//
//  Created by Ryan David Forsyth on 2020-09-07.
//  Copyright © 2020 Ryan David Forsyth. All rights reserved.
//

import SwiftUI

enum direction {
    case up, down, left, right
}

struct ContentView: View {
    
    @State var startPos : CGPoint = .zero // the start poisition of our swipe
    @State var isStarted = true // did the user started the swipe?
    @State var gameOver = false // for ending the game when the snake hits the screen borders
    
    @State var dir = direction.down // the direction the snake is going to take
    
    @State var snakePosArray: [CGPoint] = Array(repeating: CGPoint(x: 0, y: 0), count: 100) // array of the snake's body positions
    
    @State var tailPosArray: [CGPoint] = []
    
    @State var goalPos = CGPoint(x: 0, y: 0) // the position of the food
    
    let snakeSize : CGFloat = 10 // width and height of the snake
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // to updates the snake position every 0.1 second

    let minX = UIScreen.main.bounds.minX
    let maxX = UIScreen.main.bounds.maxX
    let minY = UIScreen.main.bounds.minY
    let maxY = UIScreen.main.bounds.maxY
    
    func changeRectPos() -> CGPoint {
        let rows = Int(maxX/snakeSize)
        let cols = Int(maxY/snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    func updateSnake () {
        
        if self.snakePosArray[0].x < minX
            || self.snakePosArray[0].x > maxX
            && !gameOver {
            Haptics.notification(forType: .warning)
            gameOver.toggle()
        }
        else if self.snakePosArray[0].y < minY
            || self.snakePosArray[0].y > maxY
            && !gameOver {
            Haptics.notification(forType: .warning)
            gameOver.toggle()
        }
        
        var prev = snakePosArray[0]
        if dir == .down {
            self.snakePosArray[0].y += snakeSize
        } else if dir == .up {
            self.snakePosArray[0].y -= snakeSize
        } else if dir == .left {
            self.snakePosArray[0].x += snakeSize
        } else {
            self.snakePosArray[0].x -= snakeSize
        }
        
        for index in 1..<snakePosArray.count {
            let current = snakePosArray[index]
            snakePosArray[index] = prev
            prev = current
        }
        
        for index in 1..<snakePosArray.count { // Collision with self
            if (self.snakePosArray[index].equalTo(self.snakePosArray[0])) {
                Haptics.notification(forType: .warning)
                gameOver.toggle()
            }
        }
    }
    
    func resetGame() {
        self.goalPos = self.changeRectPos()
        self.snakePosArray[0] = self.changeRectPos()
        self.gameOver = false
        Haptics.notification(forType: .success)
    }
    
    func startOver() {
        self.snakePosArray = [(CGPoint(x: 0, y: 0))]
        self.resetGame()
    }
    
    var body: some View {
        ZStack {
            Color.init(UIColor.systemBackground)
            
            ZStack {
                
                ForEach (0..<snakePosArray.count, id: \.self) { index in
                    Circle()
                        .frame(width: self.snakeSize, height: self.snakeSize)
                        .position(self.snakePosArray[index])
                }
                
                ForEach (0..<tailPosArray.count, id: \.self) { index in
                    Circle()
                        .fill(Color.init(UIColor.systemRed))
                        .frame(width: self.snakeSize, height: self.snakeSize)
                        .position(self.tailPosArray[index])
                }
                
                Circle()
                    .fill(Color.init(UIColor.systemGreen))
                    .frame(width: snakeSize, height: snakeSize)
                    .position(goalPos)
            }
            
            if self.gameOver {
                HStack {
                    Button("Continue") {
                        self.resetGame()
                    }
                    Button("Start Over") {
                        self.startOver()
                    }
                }
                
            }
        }
        .gesture(DragGesture()
        .onChanged { gesture in
            if self.isStarted {
                self.startPos = gesture.location
                self.isStarted.toggle()
            }
        }
        .onEnded {  gesture in
            let xDist =  abs(gesture.location.x - self.startPos.x)
            let yDist =  abs(gesture.location.y - self.startPos.y)
            if self.startPos.y <  gesture.location.y && yDist > xDist {
                if self.dir == .down {
                    
                }
                else {
                    self.dir = .down
                }
                
                Haptics.selection()
            }
            else if self.startPos.y >  gesture.location.y && yDist > xDist {
                self.dir = .up
                Haptics.selection()
            }
            else if self.startPos.x > gesture.location.x && yDist < xDist {
                self.dir = .right
                Haptics.selection()
            }
            else if self.startPos.x < gesture.location.x && yDist < xDist {
                self.dir = .left
                Haptics.selection()
            }
            self.isStarted.toggle()
        })
        .onReceive(timer) { (_) in
            if !self.gameOver {
                
                self.updateSnake()
                
                if self.snakePosArray[0] == self.goalPos {
                    self.snakePosArray.popLast()
                    self.tailPosArray.append(self.goalPos)
                    self.goalPos = self.changeRectPos()
                    Haptics.notification(forType: .success)
                }
            }
        }
        .animation(.default)
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            self.resetGame()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
