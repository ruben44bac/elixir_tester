defmodule GuiltySpark.AddTokenCommand do
	defstruct [
		:token,
		:user_id,
		:type,
		:name,
		:email,
		:channel_id,
		:sesion_id
	]
	use ExConstructor
end
