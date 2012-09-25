mongoose = require 'mongoose'
Schema = mongoose.Schema

toLower = (v) ->
	return v.toLowerCase()


BreakSchema = new Schema
	#id						:			{type: Number, index: true, unique: true, required: true}
	headline			:			{type: String}
	user					:			{type: String}
	score					:			{type: Number, default: 1}
	loc						:			{lon: Number, lat: Number}
	location_name	:			{type: String}
	story					:			{type: String, index: true}
	date					:			{type: Date, default: Date.now}
	tags					:			{type: String}
	publish				:			{type: Boolean, default: false}
	comments			:			[Comment]
	

BreakSchema.index {loc: '2d'}

UserSchema = new Schema
	id 				:		{type: Number, required: true, unique: true, index: true}
	fName			:		{type: String, required: true}
	lName			:		{type: String, required: true}
	nName			:		{type: String, required: true, unique: true}
	email			:		{type: String, set: toLower, required: true, unique: true}
	date			:		{type: Date, default: Date.now}
	beta			:		{type: Boolean, default: false}
	phone			:		{type: String, required: true}
	breaks		:		[Break]

AlbumSchema = new Schema
	name			:		{type: String, unique: true, index: true}
	date			:		{type: Date, default: Date.now}
	breaks		:		[Break]
	topBreak	:		[Break]
	location	:		{lon: Number, lat: Number}

AlbumSchema.index {loc: '2d'}

CommentSchema = new Schema
	comment		:		{type: String}
	date			:		{type: String}

Break			= mongoose.model 'Break', BreakSchema
User			= mongoose.model 'User', UserSchema
Comment		= mongoose.model 'Comment', CommentSchema
Album			=	mongoose.model 'Album', AlbumSchema

exports.User			= User
exports.Break			= Break
exports.Comment		= Comment
exports.Album			= Album
