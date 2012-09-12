mongoose = require 'mongoose'
Schema = mongoose.Schema

toLower = (v) ->
	return v.toLowerCase()


BreakSchema = new Schema
	id						:			{type: Number, index: true}
	headline			:			{type: String}
	user					:			{type: String}
	points				:			{type: Number, default: 1}
	loc						:			{lon: Number, lat: Number}
	location_name	:			{type: String}
	story					:			{type: String, index: true}
	date					:			{type: Date, default: Date.now}
	tags					:			{type: String}
	publish				:			{type: Boolean, default: false}
	comments			:			[Comment]

BreakSchema.index {loc: '2d'}

UserSchema = new Schema
	fName			:		{type: String}
	lName			:		{type: String}
	nName			:		{type: String}
	email			:		{type: String, set: toLower}
	date			:		{type: Date, default: Date.now}
	beta			:		{type: Boolean, default: false}
	phone			:		{type: String}
	breaks		:		[Break]

CommentSchema = new Schema
	comment		:		{type: String}
	date			:		{type: String}

Break			= mongoose.model 'Break', BreakSchema
User			= mongoose.model 'User', UserSchema
#Feedback	= mongoose.model 'Feedback', FeedbackSchema
Comment		= mongoose.model 'Comment', CommentSchema

exports.User			= User
exports.Break			= Break
#exports.Feedback	= Feedback
exports.Comment		= Comment
