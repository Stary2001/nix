#!/usr/bin/env python3

import serial
import requests
import re

auth = ("rpi", "0LnpgJXOdIHFos0L")

serial_port = "/dev/serial/by-id/usb-Raspberry_Pi_Pico_E66038B7138B9F31-if00"
ser = serial.Serial(serial_port)

while True:
	n = 10
	avg = 0

	# currently set to 5 sec, so n=12
	for i in range(0, n):
		avg += float(ser.readline().strip())

	requests.post("https://influx.9net.org/write?db=stary", auth=auth, data=f"home_light light_lux={avg / n}")
