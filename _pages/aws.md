---
layout: single
title: Amazon
permalink: /gettingstarted/aws/
---

If you already have an AWS account, just go to [Portal creation](http://ncar.github.io/chords/create.html).


## 1. Sign up in AWS
* Go to the <a href="https://aws.amazon.com/s/dm/optimization/server-side-test/free-tier/free_np/">amazon</a> web services website. Click on start a <em>free</em> account. We generally recommend the small account (t2.small) as it has more space for recording data and won’t overwhelm as quickly as the micro account (t2.micro). However, if you are unsure as to which account will suit you the micro account is free the first year and you can upgrade if you end up running out of space. For more information on the instance types click on the link below.
<a href=" https://aws.amazon.com/ec2/instance-types/ "> https://aws.amazon.com/ec2/instance-types/ </a>

**Note:** when you first sign into your account it’s automatically signed up for all services in AWS (e.g. lambda). You are only charged for the services that you use. For more information visit <a href=" https://aws.amazon.com/lambda/  "> https://aws.amazon.com/lambda/  </a>
<figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_START.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_START.PNG"></a>
</figure>
<br>
<hr>

* Enter your email and create a password. Make sure to select “I am a new user” If you don’t have an amazon account.
* Walk through their online setup and make a note of your **ID**
  - **Note:** <em>There will be a section where you will need to provide a credit card number and enter a PIN via a phone call from Amazon</em>
  <figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_Step1.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step1.PNG"></a>
  </figure>
  Please <em>keep a note of your AWS account ID</em>, you'll need it next.

<br>
<hr>
  
## 2. Create an IAM User (Security)
* Sign into <em> Identity and Access Management</em> (IAM) console at <a href="https://console.aws.amazon.com/iam/">https://console.aws.amazon.com/iam/</a>
* In the navigation pane select **Users**, and then click <em>**Add User**</em>
<br>
<hr>
<figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_Step2.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step2.PNG"></a>
</figure>

* Type in a user name.
  - Amazon.com states that, “The name can consist of letters, digits, and the following characters: plus (+), equal (=), comma (,), period (.), at (@), underscore (_), and hyphen (-). The name is not case sensitive and can be a maximum of 64 characters in length.” 
Quoted from http://docs.aws.amazon.com/lambda/latest/dg/setting-up.html

* Click the checkbox next to **AWS Management Console access**, select **Custom password**, type the new user’s password in the text box and unclick **Require password reset**. You can also select Programmatic access which will give the user more access to the key ID and secret access key.
<figure>
    <a href ="{{ site.baseurl }}/assets/images/AWS_Step3.PNG"> <img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step3.PNG"></a>
</figure>

* When you hit next you’ll see a page about groups and users. Select **Attach existing policies directly** and check the first box in the window below, **AdministratorAccess**.
<figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_Step3.5.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step3.5.PNG"></a>
</figure>
Move onto the **Review** step. Here you can double check your user and what permissions they have before creating their account. If this looks OK, click on **Create user**.


## 3. Sign in as the new IAM user

* In the green "Success" shaded area, note the link at the bottom that says "Users with AWS Management Console access can sign-in at:", which looks like this:
````
https://[aws account number goes here].signin.aws.amazon.com/console/
````
 - Remember your AWS account ID? You’re going to use it as your aws_account_number without the hyphen. 
 
 e.g. 1234-5678-9101 is 123456789101 so the link you end up with should look like: 
 `````
 https://123456789101.signin.aws.amazon.com/console/
`````
**Note:** If you need to find your account number again go to “Your AWS Account ID and It’s Alias” at http://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html

* Click on the link provided by AWS and enter the IAM username and password you made. Once you’ve successfully logged in your navigation bar at the top should show <em> your_user_name@your_aws_account_id </em>
<figure>
    <a href ="{{ site.baseurl }}/assets/images/AWS_Step4.PNG"> <img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step4.PNG"></a>
</figure>

## 4. Create a Key Pair

* Bring up EC2 Services by Selecting **Services** on the top bar:
<figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_Step4.5.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step4.5.PNG" ></a>
</figure>

* Click on **EC2**
<figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_Step5.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step5.PNG"></a>
</figure> 

* Select **Key Pairs** on the left
<figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_Step6.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step6.PNG"></a>
</figure>

* Click **Create Key Pair** and enter a Key pair name:
<figure>
    <a href = "{{ site.baseurl }}/assets/images/AWS_Step7.PNG"><img class="img-responsive" src="{{ site.baseurl }}/assets/images/AWS_Step7.PNG"></a>
</figure>
All done, now go to this link to [Create a Portal via AWS](http://ncar.github.io/chords/create.html)! <!--this needs changed to go to current website link-->
