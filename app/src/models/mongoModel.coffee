mongoose = require 'mongoose'
Schema = mongoose.Schema

toLower = (v) ->
	return v.toLowerCase()

CommentSchema = new Schema
	comment		:		{type: String}
	date			:		{type: Date, default: Date.now}
	user : {type: String}

BreakSchema = new Schema
	headline			:			{type: String}
	upvotes					:			{type: Number, default: 1}
	downvotes				:			{type: Number, default: 0}
	startingPoints			:			{type: Number}
	points 				:				{type: Number}
	views				:				{type: Number, default: 0}
	loc						:			{lon: Number, lat: Number}
	location_name		:			{type: String}
	album				:			{type: String, default: null}
	user				:			{type: String, default: null}
	top					:			{type: Boolean, default: false}
	story					:			{type: String, index: true}
	date					:			{type: Date, default: Date.now}
	tags					:			{type: String}
	publish				:			{type: Boolean, default: true}
	comments			:			[Comment]
	fbShares			:			[Schema.ObjectId]
	tweets				:			[Schema.ObjectId]

BreakSchema.index {loc: '2d'}

UserSchema = new Schema
	fName			:		{type: String, required: true}
	lName			:		{type: String, required: true}
	nName			:		{type: String, required: true, unique: true}
	email			:		{type: String, set: toLower, required: true, unique: true, index: true}
	date			:		{type: Date, default: Date.now}
	phone			:		{type: String, required: true}
	breaks		:		[Schema.ObjectId]
	
#UserSchema.index {email: 1}

#This is only for receiving beta registrations
BetaSchema = new Schema
	email			:		{type: String, set: toLower, required: true, unique: true}
	date			:		{type: Date, default: Date.now}
	phone			:		{type: String, required: true}

AlbumSchema = new Schema
	name			:		{type: String, index: true}
	date			:		{type: Date, default: Date.now}
	breaks		:		[Schema.ObjectId]
	topBreak	:		Schema.Types.Mixed
	loc				:		{lon: Number, lat: Number}

AlbumSchema.index {loc: '2d'}

FeedbackSchema = new Schema
	user_id		:		{type: String}
	date			:		{type: Date, default: Date.now}
	comment		:		{type: String}

Feedback	= mongoose.model 'Feedback', FeedbackSchema
Comment		= mongoose.model 'Comment', CommentSchema
Break			= mongoose.model 'Break', BreakSchema
User			= mongoose.model 'User', UserSchema
BetaUser = mongoose.model 'BetaUser', BetaSchema
Album			=	mongoose.model 'Album', AlbumSchema




exports.User			= User
exports.BetaUser = BetaUser
exports.Break			= Break
exports.Comment		= Comment
exports.Album			= Album
exports.Feedback		= Feedback
