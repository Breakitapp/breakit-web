mongoose = require 'mongoose'
Schema = mongoose.Schema

toLower = (v) ->
	return v.toLowerCase()


BreakSchema = new Schema
	#id						:			{type: Number, index: true, unique: true, required: true}
	headline			:			{type: String}
	user					:			{type: String}
	
	score					:			{type: Number, default: 1}
	#maybe we should save upvotes and downvotes separately? -e
	
	points 				:				{type: Number}
	loc						:			{lon: Number, lat: Number}
	location_name	:			{type: String}
	album			:			{type: String, default: null}
	story					:			{type: String, index: true}
	date					:			{type: Date, default: Date.now}
	tags					:			{type: String}
	publish				:			{type: Boolean, default: false}
	comments			:			[Comment]

BreakSchema.index {loc: '2d'}

UserSchema = new Schema
	fName			:		{type: String, required: true}
	lName			:		{type: String, required: true}
	nName			:		{type: String, required: true}
	email			:		{type: String, set: toLower, required: true, index: true}
	date			:		{type: Date, default: Date.now}
	beta			:		{type: Boolean, default: false}
	phone			:		{type: String, required: true}
	breaks		:		[Break]

#This is only for receiving beta registrations
BetaSchema = new Schema
	email			:		{type: String, set: toLower, required: true, unique: true}
	date			:		{type: Date, default: Date.now}
	phone			:		{type: String, required: true}

AlbumSchema = new Schema
	name			:		{type: String, index: true}
	date			:		{type: Date, default: Date.now}
	breaks		:		[String]
	#topBreak	:		[Break]
	loc				:		{lon: Number, lat: Number}

AlbumSchema.index {loc: '2d'}

CommentSchema = new Schema
	comment		:		{type: String}
	date			:		{type: Date, default: Date.now}
	user : {type: String}

FeedbackSchema = new Schema
	user_id		:		{type: String}
	date			:		{type: Date, default: Date.now}
	comment		:		{type: String}
		

Feedback	= mongoose.model 'Feedback', FeedbackSchema
Break			= mongoose.model 'Break', BreakSchema
User			= mongoose.model 'User', UserSchema
BetaUser = mongoose.model 'BetaUser', BetaSchema
Comment		= mongoose.model 'Comment', CommentSchema
Album			=	mongoose.model 'Album', AlbumSchema



exports.User			= User
exports.BetaUser = BetaUser
exports.Break			= Break
exports.Comment		= Comment
exports.Album			= Album
exports.Feedback		= Feedback
