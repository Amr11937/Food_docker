// import mongoose from "mongoose";

// export const  connectDB = async () =>{
//     await mongoose.connect('mongodb://gofood:gofood@ac-ahbopyo-shard-00-00.yyuenjg.mongodb.net:27017,ac-ahbopyo-shard-00-01.yyuenjg.mongodb.net:27017,ac-ahbopyo-shard-00-02.yyuenjg.mongodb.net:27017/gofood?ssl=true&replicaSet=atlas-yvcym8-shard-0&authSource=admin&retryWrites=true&w=majority&appName=Cluster0').then(()=>console.log("DB Connected"))
// }

import mongoose from "mongoose";

export const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
    console.log(`Database Name: ${conn.connection.name}`);
  } catch (error) {
    console.error("Error connecting to MongoDB:", error.message);
    process.exit(1);
  }
};
