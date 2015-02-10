//
//  NotificationsFilterBar.swift
//  Ello
//
//  Created by Colin Gray on 2/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble


class NotificationsFilterBarSpec: QuickSpec {
    override func spec() {
        var subject = NotificationsFilterBar()
        var button1 = UIButton()
        var button2 = UIButton()
        var button3 = UIButton()
        var buttons : [UIButton] = []
        var rect = CGRect(x:0,y:0,width:0,height:0)

        describe("Is not broken") {
            it("can be created") {
                expect(NotificationsFilterBar()).notTo(beNil())
            }
            it("is a UIView") {
                expect(NotificationsFilterBar()).to(beAKindOf(UIView))
            }
        }
        describe("Can contain buttons") {

            beforeEach() {
                subject = NotificationsFilterBar(frame: CGRect(x: 0, y: 0, width: 92, height: 30))
                button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                button2 = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                button3 = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                buttons = [button1, button2, button3]
            }
            it("-setButtons") {
                subject.buttons = buttons
                expect(subject.buttons.count).to(equal(3))
                expect(subject.buttons).to(equal(buttons))
                expect(button1.superview).to(equal(subject))
                expect(button2.superview).to(equal(subject))
                expect(button3.superview).to(equal(subject))
            }
            describe("-layoutSubviews") {
                beforeEach() {
                    subject.buttons = buttons
                    subject.layoutIfNeeded()
                }
                describe("should layout button1") {
                    beforeEach() {
                        rect = CGRect(x: 0, y: 0, width: 30, height: 30)
                    }
                    it("should set x") {
                        expect(button1.frame.origin.x).to(equal(rect.origin.x))
                    }
                    it("should set y") {
                        expect(button1.frame.origin.y).to(equal(rect.origin.y))
                    }
                    it("should set width") {
                        expect(button1.frame.size.width).to(equal(rect.size.width))
                    }
                    it("should set height") {
                        expect(button1.frame.size.height).to(equal(rect.size.height))
                    }
                }
                describe("should layout button2") {
                    beforeEach() {
                        rect = CGRect(x: 31, y: 0, width: 30, height: 30)
                    }
                    it("should set x") {
                        expect(button2.frame.origin.x).to(equal(rect.origin.x))
                    }
                    it("should set y") {
                        expect(button2.frame.origin.y).to(equal(rect.origin.y))
                    }
                    it("should set width") {
                        expect(button2.frame.size.width).to(equal(rect.size.width))
                    }
                    it("should set height") {
                        expect(button2.frame.size.height).to(equal(rect.size.height))
                    }
                }
                describe("should layout button3") {
                    beforeEach() {
                        rect = CGRect(x: 62, y: 0, width: 30, height: 30)
                    }
                    it("should set x") {
                        expect(button3.frame.origin.x).to(equal(button3.frame.origin.x))
                    }
                    it("should set y") {
                        expect(button3.frame.origin.y).to(equal(button3.frame.origin.y))
                    }
                    it("should set width") {
                        expect(button3.frame.size.width).to(equal(button3.frame.size.width))
                    }
                    it("should set height") {
                        expect(button3.frame.size.height).to(equal(button3.frame.size.height))
                    }
                }
            }
            it("-addButton") {
                subject.addButton(button1)
                subject.addButton(button2)
                subject.addButton(button3)
                expect(subject.buttons.count).to(equal(3))
                expect(subject.buttons).to(equal(buttons))
                expect(button1.superview).to(equal(subject))
                expect(button2.superview).to(equal(subject))
                expect(button3.superview).to(equal(subject))
            }
            it("selectButton") {
                subject.buttons = buttons
                subject.selectButton(button1)
                expect(button1.selected).to(equal(true))
                expect(button2.selected).to(equal(false))
                expect(button3.selected).to(equal(false))
            }
        }
    }
}
