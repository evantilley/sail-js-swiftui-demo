

module.exports = {

	//get
	getUsers: async (req, res) => {
		var users = await sails.models.user.find();
		res.send(users);
	},

	//post
	createUser: async (req, res) => {
		//getting parameters as header
		var header = req.headers;
		var username = header['username'];
		var password = header['password'];

		//creating user

		await sails.models.user.create({username: username, password: password}).exec((err) => {
			// exec <=> completion hander

			//returning string status
			if (err != null){
				return res.send("fail")
			} else{
				return res.send("pass")
			}
		})
	},

	deleteUser: async (req, res) => {
		var id = req.headers['id']
		await User.destroy({id: id}).exec((err) => {
			if (err != null){
				return res.send("FAIL")
			} else{
				res.send("PASS")
			}
		})
	}

}


