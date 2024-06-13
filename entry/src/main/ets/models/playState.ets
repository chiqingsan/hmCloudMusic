import { songItemType } from './music';

// 播放器通知页面的数据结构
export interface PlayStateType {
  img: string
  name: string
  author: string
  url: string
  playIndex: number
  time: number
  duration: number
  isPlay: boolean
  playMode: 'auto' | 'repeat' | 'random'
  playList: songItemType[]
}
export class PlayStateTypeModel implements PlayStateType {
  img: string = ''
  name: string = ''
  author: string = ''
  url: string = ''
  playIndex: number = 0
  time: number = 0
  duration: number = 0
  isPlay: boolean = false
  playMode: 'auto' | 'repeat' | 'random' = 'auto'
  playList: songItemType[] = []

}
