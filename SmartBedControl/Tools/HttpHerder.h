//
//  HttpHerder.h
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/26.
//

#ifndef HttpHerder_h
#define HttpHerder_h

#define  httpIP @"http://47.107.92.138:18080"

//注册
#define  userRegister @"/api/user/register"

//获取验证码
#define getPhoneCode @"/api/user/verification/send"

//修改密码
#define eidtPassword @"/api/user/password/edit"

//忘记密码，密码重置
#define passwordReset @"/api/user/password/reset"

//登录
#define userLogin @"/api/user/login"


#endif /* HttpHerder_h */
