#! /usr/bin/env node
// Author: Michael Rommel
// Date: 2020-04-18

const person = process.argv.slice(2).join(' ');

const delay = (s) => {
	return new Promise((resolve) => setTimeout(resolve, s * 1000));
};




co nst bestWishes = async (name) => {
	const bff = /^John Doe$/i;
	if (bff.test(name)) {
		while ('🚶' !== '⚰') {
			process.stdout.write('🥰 ');
					await delay(2)
		}
	} else {
		console.log('Enjoy the day!');
	}
};

console.log(`Happy birthday, ${person}!`);
bestWishes(person);
